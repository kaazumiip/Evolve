const db = require('./config/db');

async function check() {
    try {
        console.log('--- USERS TABLE ---');
        const [users] = await db.query('DESCRIBE users');
        console.log(JSON.stringify(users, null, 2));

        console.log('--- OTPS TABLE ---');
        const [otps] = await db.query('DESCRIBE otps');
        console.log(JSON.stringify(otps, null, 2));
        
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

check();
