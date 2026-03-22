const db = require('./config/db');

async function migrateScholarships() {
    try {
        await db.execute(`
            IF COL_LENGTH('scholarships', 'type') IS NULL
            BEGIN
                ALTER TABLE scholarships ADD type NVARCHAR(100);
            END
        `);
        console.log('Added type column');

        await db.execute(`
            IF COL_LENGTH('scholarships', 'eligibility') IS NULL
            BEGIN
                ALTER TABLE scholarships ADD eligibility NVARCHAR(MAX);
            END
        `);
        console.log('Added eligibility column');

        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

migrateScholarships();
