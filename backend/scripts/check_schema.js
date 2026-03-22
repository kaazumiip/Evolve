const sql = require('mssql');
const fs = require('fs');
require('dotenv').config();

const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: '127.0.0.1',
    port: 51785,
    database: process.env.DB_NAME,
    options: {
        encrypt: false,
        trustServerCertificate: true,
    },
};

async function checkSchema() {
    let output = '';
    try {
        let pool = await sql.connect(config);
        output += 'Connected to SQL Server\n';

        const tables = ['messages', 'conversations', 'conversation_participants', 'users'];

        for (const table of tables) {
            output += `\n--- Schema for ${table} ---\n`;
            const result = await pool.request().query(`
        SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = '${table}'
      `);
            output += JSON.stringify(result.recordset, null, 2) + '\n';
        }

        fs.writeFileSync('schema_info.json', output);
        console.log('Schema info written to schema_info.json');
        await sql.close();
    } catch (err) {
        fs.writeFileSync('schema_error.txt', err.stack);
        console.error('Error:', err);
    }
}

checkSchema();
