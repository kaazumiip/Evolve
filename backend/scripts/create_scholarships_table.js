const db = require('./config/db');

async function createScholarshipsTable() {
    try {
        const query = `
            IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='scholarships' AND xtype='U')
            BEGIN
                CREATE TABLE scholarships (
                    id INT IDENTITY(1,1) PRIMARY KEY,
                    title NVARCHAR(255) NOT NULL,
                    provider NVARCHAR(255),
                    amount NVARCHAR(100),
                    deadline NVARCHAR(100),
                    applicantsCount NVARCHAR(50),
                    pacing NVARCHAR(100),
                    description NVARCHAR(MAX),
                    requirements NVARCHAR(MAX),
                    processes NVARCHAR(MAX),
                    quickFacts NVARCHAR(MAX),
                    aboutProvider NVARCHAR(MAX),
                    providerDetails NVARCHAR(MAX),
                    checklist NVARCHAR(MAX),
                    color NVARCHAR(50),
                    website NVARCHAR(255),
                    created_at DATETIME2 DEFAULT GETDATE(),
                    expires_at DATETIME2
                );
                PRINT 'Scholarships table created successfully.';
            END
            ELSE
            BEGIN
                PRINT 'Scholarships table already exists.';
            END
        `;

        await db.execute(query);
        console.log('Database operation completed.');
        process.exit(0);
    } catch (error) {
        console.error('Error creating scholarships table:', error);
        process.exit(1);
    }
}

createScholarshipsTable();
