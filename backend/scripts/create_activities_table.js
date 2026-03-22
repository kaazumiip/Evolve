const db = require('./config/db');

async function createActivitiesTable() {
    try {
        await db.execute(`
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='activities' and xtype='U')
            CREATE TABLE activities (
                id INT IDENTITY(1,1) PRIMARY KEY,
                user_id NVARCHAR(255) NOT NULL,
                action_type NVARCHAR(50) NOT NULL,
                entity_title NVARCHAR(255) NOT NULL,
                created_at DATETIME2 DEFAULT GETDATE()
            )
        `);
        console.log("Activities table created or already exists.");
        process.exit(0);
    } catch (err) {
        console.error("Error creating activities table:", err);
        process.exit(1);
    }
}

createActivitiesTable();
