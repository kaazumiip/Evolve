const mysql = require('mysql2/promise');
require('dotenv').config();

const config = {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: {
    rejectUnauthorized: false
  },
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  timezone: '+07:00' // Ensure MySQL dates match local time (+07:00)
};

// Use full DATABASE_URL if available (solves Railway DNS / IPv6 issues)
const poolConnectionConfig = process.env.DATABASE_URL 
  ? { uri: process.env.DATABASE_URL.replace('?ssl-mode=REQUIRED', ''), ssl: { rejectUnauthorized: false } }
  : config;

const pool = mysql.createPool(poolConnectionConfig);

// Add a connection initialization to set timezone forcefully for each session
pool.on('connection', (connection) => {
    connection.query("SET time_zone = '+07:00'");
});

/**
 * Smart SQL Translator: Converts existing MSSQL-dialect queries to MySQL
 * This ensures the application keeps running without rewriting every controller.
 */
function translateDialect(query) {
  let processed = query;

  // 1. Datetime conversions
  processed = processed.replace(/SYSUTCDATETIME\(\)/gi, 'UTC_TIMESTAMP()');
  processed = processed.replace(/GETDATE\(\)/gi, 'NOW()');
  
  // 2. Pagination: OFFSET ? ROWS FETCH NEXT ? ROWS ONLY -> LIMIT ?, ?
  // Note: MySQL LIMIT order is (offset, count).
  processed = processed.replace(/OFFSET\s+(\?|\d+)\s+ROWS\s+FETCH\s+NEXT\s+(\?|\d+)\s+ROWS\s+ONLY/gi, 'LIMIT $1, $2');

  // 3. TOP conversion (e.g. SELECT TOP 10 * -> SELECT * ... LIMIT 10)
  if (/SELECT\s+TOP\s+(\d+)/i.test(processed)) {
    const limitMatch = processed.match(/SELECT\s+TOP\s+(\d+)/i);
    const limit = limitMatch ? limitMatch[1] : '';
    processed = processed.replace(/SELECT\s+TOP\s+(\d+)/gi, 'SELECT');
    processed += ` LIMIT ${limit}`;
  }

  // 4. Specific streak logic: DATEADD/DATEDIFF (MSSQL) -> MySQL Equiv
  processed = processed.replace(/DATEADD\(day, -DATEDIFF\(day, 0, NOW\(\)\) % 7, CAST\(NOW\(\) AS DATE\)\)/gi, 
    'DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) + 5) % 7 DAY)');

  // 5. NVARCHAR -> VARCHAR
  processed = processed.replace(/NVARCHAR/gi, 'VARCHAR');

  return processed;
}

/**
 * Handle Database Creation for Aiven
 */
async function ensureDatabaseExists() {
  try {
    // If using DATABASE_URL, don't attempt manual DB creation as it's handled by URI
    if (process.env.DATABASE_URL) {
       console.log("Using DATABASE_URL, skipping manual DB creation check.");
       return;
    }

    const connection = await mysql.createConnection({
      host: config.host,
      port: config.port,
      user: config.user,
      password: config.password,
      ssl: config.ssl
    });

    console.log(`Checking if database '${config.database}' exists...`);
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${config.database}\``);
    console.log(`Database '${config.database}' is ready!`);
    await connection.end();
  } catch (err) {
    console.warn(`Could not verify/create database: ${err.message}`);
  }
}

// Global pool instance
let poolInstance = null;

async function getPool() {
  if (poolInstance) return poolInstance;
  
  await ensureDatabaseExists();
  poolInstance = mysql.createPool(poolConnectionConfig);
  return poolInstance;
}

module.exports = {
  execute: async (query, params = []) => {
    try {
      const pool = await getPool();
      const translatedQuery = translateDialect(query);
      
      const sanitizedParams = params;

      // USE query() instead of execute() for LIMIT/OFFSET
      // MySQL Prepared Statements (execute) can be restrictive with LIMIT parameters
      if (translatedQuery.toUpperCase().includes('LIMIT')) {
        const [rows] = await pool.query(translatedQuery, sanitizedParams);
        if (translatedQuery.trim().toUpperCase().startsWith('INSERT')) {
          return [{ insertId: rows.insertId, affectedRows: rows.affectedRows }, null];
        }
        return [rows, null];
      }

      const [rows] = await pool.execute(translatedQuery, sanitizedParams);
      if (translatedQuery.trim().toUpperCase().startsWith('INSERT')) {
        return [{ insertId: rows.insertId, affectedRows: rows.affectedRows }, null];
      }
      return [rows, null];
    } catch (err) {
      console.error('Database Query Error:', err);
      throw err;
    }
  },

  query: async (query, params = []) => {
    return module.exports.execute(query, params);
  },

  getConnection: async () => {
    const pool = await getPool();
    const connection = await pool.getConnection();
    
    return {
      beginTransaction: () => connection.beginTransaction(),
      commit: () => connection.commit(),
      rollback: () => connection.rollback(),
      execute: async (query, params = []) => {
        const translatedQuery = translateDialect(query);
        const sanitizedParams = params;

        // Use query() for LIMIT in transactions too
        if (translatedQuery.toUpperCase().includes('LIMIT')) {
          const [rows] = await connection.query(translatedQuery, sanitizedParams);
          if (translatedQuery.trim().toUpperCase().startsWith('INSERT')) {
            return [{ insertId: rows.insertId, affectedRows: rows.affectedRows }, null];
          }
          return [rows, null];
        }

        const [rows] = await connection.execute(translatedQuery, sanitizedParams);
        if (translatedQuery.trim().toUpperCase().startsWith('INSERT')) {
          return [{ insertId: rows.insertId, affectedRows: rows.affectedRows }, null];
        }
        return [rows, null];
      },
      query: async (query, params = []) => {
        return module.exports.execute(query, params);
      },
      release: () => connection.release()
    };
  }
};
