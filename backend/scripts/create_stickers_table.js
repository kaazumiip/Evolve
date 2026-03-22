const db = require('./config/db');

async function createStickersTable() {
    try {
        await db.execute(`
            IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'stickers')
            BEGIN
                CREATE TABLE stickers (
                    id INT IDENTITY(1,1) PRIMARY KEY,
                    user_id INT NOT NULL,
                    name NVARCHAR(255) NOT NULL,
                    image_url NVARCHAR(255) NOT NULL,
                    is_public BIT DEFAULT 0,
                    created_at DATETIME DEFAULT GETDATE(),
                    CONSTRAINT FK_Stickers_Users FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                )
            END
        `);
        console.log('Stickers table created successfully');
        process.exit(0);
    } catch (error) {
        console.error('Error creating stickers table:', error);
        process.exit(1);
    }
}

createStickersTable();
