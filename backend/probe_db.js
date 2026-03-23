const db = require('./config/db');
const fs = require('fs');

async function check() {
    try {
        let log = '';
        const [usersIdx] = await db.query('SHOW INDEX FROM users');
        log += '--- USERS INDEXES ---\n';
        usersIdx.forEach(idx => log += `${idx.Key_name}: ${idx.Column_name} (${idx.Non_unique ? 'Non-unique' : 'Unique'})\n`);

        const [otpsIdx] = await db.query('SHOW INDEX FROM otps');
        log += '--- OTPS INDEXES ---\n';
        otpsIdx.forEach(idx => log += `${idx.Key_name}: ${idx.Column_name} (${idx.Non_unique ? 'Non-unique' : 'Unique'})\n`);
        
        fs.writeFileSync('schema_log.txt', log);
        process.exit(0);
    } catch (e) {
        fs.writeFileSync('schema_log.txt', e.toString());
        process.exit(1);
    }
}

check();
