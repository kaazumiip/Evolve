const db = require('../config/db');

async function updateSchema() {
    const query = `
        IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'is_password_set')
        BEGIN
            ALTER TABLE users ADD is_password_set BIT DEFAULT 0;
            -- For existing users who have passwords (longer than modern hashes or from non-google registration)
            -- But we can't easily tell, so let's default 0 for now and they can set it.
            -- Actually, for standard email users, it should be 1.
            EXEC('UPDATE users SET is_password_set = 1 WHERE google_id IS NULL AND facebook_id IS NULL');
        END
    `;
    try {
        await db.execute(query);
        console.log('Successfully added is_password_set column');
        process.exit(0);
    } catch (err) {
        console.error('Error updating users schema:', err);
        process.exit(1);
    }
}

updateSchema();
