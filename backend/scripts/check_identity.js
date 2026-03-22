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

async function checkIdentity() {
    let output = '';
    try {
        let pool = await sql.connect(config);
        output += 'Connected to SQL Server\n';

        const tables = ['messages', 'conversations', 'users'];

        for (const table of tables) {
            output += `\n--- Identity check for ${table} ---\n`;
            const result = await pool.request().query(`
        SELECT name, 
               is_identity 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID('${table}') AND name = 'id'
      `);
            output += JSON.stringify(result.recordset, null, 2) + '\n';
        }

        fs.writeFileSync('identity_check.json', output);
        console.log('Identity check info written to identity_check.json');
        await sql.close();
    } catch (err) {
        fs.writeFileSync('identity_error.txt', err.stack);
        console.error('Error:', err);
    }
}

checkIdentity();
