const db = require('./backend/config/db');

async function checkSchema() {
    try {
        console.log('--- FRIENDSHIPS SCHEMA ---');
        const [friendshipCols] = await db.execute('SHOW COLUMNS FROM friendships');
        console.log(friendshipCols);

        console.log('\n--- CONVERSATION_PARTICIPANTS SCHEMA ---');
        const [participantCols] = await db.execute('SHOW COLUMNS FROM conversation_participants');
        console.log(participantCols);

        process.exit(0);
    } catch (err) {
        console.error('SCHEMA CHECK FAILED:', err.message);
        process.exit(1);
    }
}

checkSchema();
