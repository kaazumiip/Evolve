const db = require('./config/db');

async function checkAndAddMediaUrlsColumn() {
    try {
        console.log('Connected to SQL Server database.');
        
        console.log('Checking if media_urls column exists in posts table...');
        const [rows] = await db.execute(`
            IF NOT EXISTS (
                SELECT * FROM sys.columns 
                WHERE object_id = OBJECT_ID('posts') AND name = 'media_urls'
            )
            BEGIN
                ALTER TABLE posts ADD media_urls NVARCHAR(MAX);
                SELECT 'ADDED' as status;
            END
            ELSE
            BEGIN
                SELECT 'EXISTS' as status;
            END
        `);
        
        if (rows && rows.length > 0 && rows[0].status === 'ADDED') {
            console.log('media_urls column added successfully.');
        } else {
            console.log('media_urls column already exists.');
        }

        process.exit(0);
    } catch (err) {
        console.error('Migration failed:', err.message);
        process.exit(1);
    }
}

checkAndAddMediaUrlsColumn();
