const { Pool, types } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

// Parse INT8 (BIGINT, e.g. COUNT(*)) as JavaScript Numbers so JSON responses match MySQL
types.setTypeParser(20, (val) => parseInt(val, 10));

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  },
  max: 15,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 15000,
});

// Map lowercase PG aliases back to camelCase expected by frontend/controllers
const CAMEL_CASE_ALIASES = {
  lastmessage: 'lastMessage',
  lastmessagetime: 'lastMessageTime',
  unreadcount: 'unreadCount',
  otheruserid: 'otherUserId',
  otherusername: 'otherUserName',
  otheruserimage: 'otherUserImage',
  otheruserlastseen: 'otherUserLastSeen',
  lastmessagetype: 'lastMessageType',
  lastmediagallery: 'lastMediaGallery',
  sendername: 'senderName',
  senderimage: 'senderImage',
  replytocontent: 'replyToContent',
  replytosendername: 'replyToSenderName',
  username: 'userName',
  userimage: 'userImage',
  likecount: 'likeCount',
  commentcount: 'commentCount',
  isliked: 'isLiked',
  posttitle: 'postTitle',
  commoninterests: 'commonInterests',
  applicantscount: 'applicantsCount',
  quickfacts: 'quickFacts',
  aboutprovider: 'aboutProvider',
  providerdetails: 'providerDetails',
  likescount: 'likesCount',
  commentscount: 'commentsCount',
  friendscount: 'friendsCount',
  friendshipstatus: 'friendshipStatus',
  requesterid: 'requesterId'
};

function normalizeRows(rows) {
  if (!Array.isArray(rows)) return rows;
  return rows.map(row => {
    const normalized = {};
    for (const key of Object.keys(row)) {
      const mappedKey = CAMEL_CASE_ALIASES[key] || key;
      normalized[mappedKey] = row[key];
    }
    return normalized;
  });
}

/**
 * Smart SQL Translator: Converts existing MySQL / MSSQL dialect queries to PostgreSQL (Supabase)
 */
function translateToPostgres(query, params = []) {
  let processed = query.trim();
  let newParams = [...params];

  // 1. Handle INSERT IGNORE -> ON CONFLICT DO NOTHING
  let isInsertIgnore = false;
  if (/INSERT\s+IGNORE\s+INTO/i.test(processed)) {
    isInsertIgnore = true;
    processed = processed.replace(/INSERT\s+IGNORE\s+INTO/gi, 'INSERT INTO');
  }

  // 2. Datetime & Dialect functions
  processed = processed.replace(/DATE_ADD\(UTC_TIMESTAMP\(\),\s*INTERVAL\s+7\s+HOUR\)/gi, 'NOW()');
  processed = processed.replace(/UTC_TIMESTAMP\(\)/gi, 'NOW()');
  processed = processed.replace(/SYSUTCDATETIME\(\)/gi, 'NOW()');
  processed = processed.replace(/GETDATE\(\)/gi, 'NOW()');
  processed = processed.replace(/DATEADD\(day,\s*30,\s*NOW\(\)\)/gi, "(NOW() + INTERVAL '30 days')");
  processed = processed.replace(/DATEADD\(day,\s*30,\s*GETDATE\(\)\)/gi, "(NOW() + INTERVAL '30 days')");

  // Boolean column compatibility (MySQL 0/1 -> PostgreSQL FALSE/TRUE)
  processed = processed.replace(/\bis_read\s*=\s*1\b/gi, 'is_read = TRUE');
  processed = processed.replace(/\bis_read\s*=\s*0\b/gi, 'is_read = FALSE');
  processed = processed.replace(/\bis_public\s*=\s*1\b/gi, 'is_public = TRUE');
  processed = processed.replace(/\bis_public\s*=\s*0\b/gi, 'is_public = FALSE');
  processed = processed.replace(/\bis_edited\s*=\s*1\b/gi, 'is_edited = TRUE');
  processed = processed.replace(/\bis_edited\s*=\s*0\b/gi, 'is_edited = FALSE');

  // Weekly login date filter
  processed = processed.replace(
    /DATE_SUB\(CURDATE\(\),\s*INTERVAL\s*\(WEEKDAY\(CURDATE\(\)\)\)\s*DAY\)/gi,
    "date_trunc('week', CURRENT_DATE)::date"
  );
  processed = processed.replace(
    /DATE_SUB\(CURDATE\(\),\s*INTERVAL\s*\(DAYOFWEEK\(CURDATE\(\)\)\s*\+\s*5\)\s*%\s*7\s*DAY\)/gi,
    "date_trunc('week', CURRENT_DATE)::date"
  );
  processed = processed.replace(
    /DATEADD\(day,\s*-DATEDIFF\(day,\s*0,\s*NOW\(\)\)\s*%\s*7,\s*CAST\(NOW\(\)\s*AS\s*DATE\)\)/gi,
    "date_trunc('week', CURRENT_DATE)::date"
  );

  // 3. Pagination: OFFSET ? ROWS FETCH NEXT ? ROWS ONLY -> LIMIT ? OFFSET ?
  if (/OFFSET\s+\?\s+ROWS\s+FETCH\s+NEXT\s+\?\s+ROWS\s+ONLY/i.test(processed)) {
    processed = processed.replace(/OFFSET\s+\?\s+ROWS\s+FETCH\s+NEXT\s+\?\s+ROWS\s+ONLY/gi, 'LIMIT ? OFFSET ?');
    if (newParams.length >= 2) {
      const len = newParams.length;
      const temp = newParams[len - 2];
      newParams[len - 2] = newParams[len - 1];
      newParams[len - 1] = temp;
    }
  }

  // 4. Case-insensitive search: LIKE -> ILIKE
  processed = processed.replace(/\bLIKE\b/gi, 'ILIKE');

  // 5. Replace ? with $1, $2, $3...
  let paramIndex = 0;
  processed = processed.replace(/\?/g, () => `$${++paramIndex}`);

  // 6. Add ON CONFLICT DO NOTHING if it was INSERT IGNORE
  if (isInsertIgnore && !/ON\s+CONFLICT/i.test(processed)) {
    processed += ' ON CONFLICT DO NOTHING';
  }

  // 7. Add RETURNING * for INSERT statements so result.insertId works
  const isInsert = /^INSERT\s+INTO/i.test(processed);
  if (isInsert && !/RETURNING\b/i.test(processed)) {
    processed += ' RETURNING *';
  }

  return { text: processed, values: newParams, isInsert };
}

async function runQuery(clientOrPool, query, params = []) {
  const { text, values, isInsert } = translateToPostgres(query, params);
  try {
    const res = await clientOrPool.query(text, values);
    const command = (res.command || '').toUpperCase();

    if (command === 'SELECT') {
      return [normalizeRows(res.rows), res.fields];
    } else {
      // INSERT, UPDATE, DELETE
      const firstRow = res.rows && res.rows[0] ? res.rows[0] : null;
      const resultHeader = {
        insertId: firstRow && firstRow.id !== undefined ? firstRow.id : null,
        affectedRows: res.rowCount,
        rowCount: res.rowCount
      };
      return [resultHeader, res.fields];
    }
  } catch (err) {
    // Map PostgreSQL unique violation (23505) so existing ER_DUP_ENTRY checks work
    if (err.code === '23505') {
      err.code = 'ER_DUP_ENTRY';
    }
    console.error('Database Query Error:', err.message, '\nSQL:', text);
    throw err;
  }
}

module.exports = {
  pool,
  execute: async (query, params = []) => {
    return runQuery(pool, query, params);
  },
  query: async (query, params = []) => {
    return runQuery(pool, query, params);
  },
  getConnection: async () => {
    const client = await pool.connect();
    return {
      beginTransaction: () => client.query('BEGIN'),
      commit: () => client.query('COMMIT'),
      rollback: () => client.query('ROLLBACK'),
      execute: (query, params = []) => runQuery(client, query, params),
      query: (query, params = []) => runQuery(client, query, params),
      release: () => client.release()
    };
  }
};
