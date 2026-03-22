const db = require('./config/db');
const fs = require('fs');

async function check() {
    try {
        let log = '';
        
        const tables = ['career_cache', 'scholarships', 'posts'];
        for (const table of tables) {
            try {
                const [cols] = await db.query(`DESCRIBE ${table}`);
                log += `--- ${table.toUpperCase()} TABLE ---\n`;
                cols.forEach(col => log += `${col.Field}: ${col.Type} (${col.Null}, ${col.Key}, ${col.Default}, ${col.Extra})\n`);
            } catch (e) {
                log += `--- ${table.toUpperCase()} TABLE MISSING OR ERROR ---\n`;
            }
        }
        
        fs.writeFileSync('schema_log.txt', log);
        process.exit(0);
    } catch (e) {
        fs.writeFileSync('schema_log.txt', e.toString());
        process.exit(1);
    }
}

check();
