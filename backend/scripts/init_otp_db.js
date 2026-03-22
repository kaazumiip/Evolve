const db = require('../config/db');

async function init() {
    const query = `
        IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[otps]') AND type in (N'U'))
        BEGIN
            CREATE TABLE [dbo].[otps] (
                [id] [int] IDENTITY(1,1) PRIMARY KEY,
                [email] [nvarchar](255) NOT NULL,
                [otp] [nvarchar](6) NOT NULL,
                [type] [nvarchar](50) NOT NULL,
                [expires_at] [datetime] NOT NULL,
                [created_at] [datetime] DEFAULT GETDATE()
            )
        END
    `;
    try {
        await db.execute(query);
        console.log('OTPs table initialized successfully');
        process.exit(0);
    } catch (err) {
        console.error('Error initializing OTPs table:', err);
        process.exit(1);
    }
}

init();
