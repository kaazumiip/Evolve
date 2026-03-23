const db = require('./config/db');
const fs = require('fs');

async function check() {
    try {
        const [columns] = await db.query('SHOW COLUMNS FROM messages');
        let log = '--- MESSAGES COLUMNS ---\n';
        columns.forEach(col => log += `${col.Field}: ${col.Type}\n`);
        
        fs.writeFileSync('schema_log.txt', log);
        console.log('Schema logged to schema_log.txt');
        process.exit(0);
    } catch (e) {
        fs.writeFileSync('schema_log.txt', e.toString());
        process.exit(1);
    }
}

check();
