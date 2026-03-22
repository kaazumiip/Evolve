const db = require('./config/db');

async function checkAndCreateStickersTable() {
    try {
        console.log('Connected to SQL Server database.');
        
        // Use db.execute which uses the mssql connection from config/db.js
        console.log('Checking if Stickers table exists...');
        const [rows] = await db.execute(`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='stickers' AND xtype='U')
            BEGIN
                CREATE TABLE stickers (
                    id INT IDENTITY(1,1) PRIMARY KEY,
                    user_id INT NOT NULL,
                    name VARCHAR(255) NOT NULL,
                    image_url VARCHAR(255) NOT NULL,
                    is_public BIT DEFAULT 0,
                    created_at DATETIME DEFAULT GETDATE(),
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                )
                SELECT 'CREATED' as status;
            END
            ELSE
            BEGIN
                SELECT 'EXISTS' as status;
            END
        `);
        
        if (rows && rows.length > 0 && rows[0].status === 'CREATED') {
            console.log('Stickers table created successfully.');
        } else {
            console.log('Stickers table already exists.');
        }

        process.exit(0);
    } catch (err) {
        console.error('Migration failed:', err.message);
        process.exit(1);
    }
}

checkAndCreateStickersTable();
