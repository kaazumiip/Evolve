const db = require('./config/db');

async function check() {
    try {
        console.log('--- CURRENT DB TIME ---');
        const [timeRows] = await db.query('SELECT UTC_TIMESTAMP() as utc_now, NOW() as local_now');
        console.log(JSON.stringify(timeRows, null, 2));

        console.log('--- LATEST OTPs ---');
        const [otps] = await db.query('SELECT * FROM otps ORDER BY expires_at DESC LIMIT 5');
        console.log(JSON.stringify(otps, null, 2));
        
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

check();
