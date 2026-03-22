const db = require('./config/db');

async function createFavoritesTable() {
    try {
        const createTableQuery = `
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='favorites' and xtype='U')
            BEGIN
                CREATE TABLE favorites (
                    id INT IDENTITY(1,1) PRIMARY KEY,
                    user_id NVARCHAR(255) NOT NULL,
                    item_type NVARCHAR(50) NOT NULL, -- 'scholarship', 'post'
                    item_id INT NOT NULL,
                    created_at DATETIME2 DEFAULT GETDATE(),
                    CONSTRAINT UQ_UserFavorite UNIQUE(user_id, item_type, item_id)
                )
            END
        `;
        await db.execute(createTableQuery);
        console.log("Favorites table checked/created successfully.");
        process.exit(0);
    } catch (error) {
        console.error("Failed to create favorites table:", error);
        process.exit(1);
    }
}

createFavoritesTable();
