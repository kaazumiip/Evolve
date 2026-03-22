const db = require('./config/db');

async function migrateCommentsTable() {
    try {
        // SQL Server (MSSQL) syntax
        await db.execute(`
            IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('comments') AND name = 'type')
            BEGIN
                ALTER TABLE comments ADD type NVARCHAR(50) DEFAULT 'text'
            END
        `);
        
        await db.execute(`
            IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('comments') AND name = 'media_url')
            BEGIN
                ALTER TABLE comments ADD media_url NVARCHAR(MAX)
            END
        `);
        
        console.log('Comments table migrated successfully');
        process.exit(0);
    } catch (error) {
        console.error('Error migrating comments table:', error);
        process.exit(1);
    }
}

migrateCommentsTable();
