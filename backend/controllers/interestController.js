const db = require('../config/db');

// Get all interests with their sub-interests
exports.getAllInterests = async (req, res) => {
    try {
        // Fetch all interests
        const [interests] = await db.execute('SELECT * FROM interests ORDER BY id ASC');

        // Fetch all sub-interests
        const [subs] = await db.execute('SELECT * FROM sub_interests ORDER BY id ASC');

        // Map sub-interests to their parent interest
        const interestsWithSubs = interests.map(interest => {
            return {
                ...interest,
                subs: subs.filter(sub => sub.interest_id === interest.id)
            };
        });

        res.json(interestsWithSubs);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
};

// Save User Interests and Sub-Interests
exports.saveUserInterests = async (req, res) => {
    const { interestIds, subInterestIds } = req.body; // Expecting arrays of IDs: [1, 2]
    const userId = req.user.id;

    if (!interestIds && !subInterestIds) {
        return res.status(400).json({ msg: 'No data provided' });
    }

    const connection = await db.getConnection();

    try {
        await connection.beginTransaction();

        // 1. Update Interests
        if (interestIds) {
            // Clear existing
            await connection.execute('DELETE FROM user_interests WHERE user_id = ?', [userId]);

            // Insert new
            if (interestIds.length > 0) {
                const interestValues = interestIds.map(id => [userId, id]);
                // Batch insert syntax: INSERT INTO table (col1, col2) VALUES ?
                // But mysql2 execute doesn't support bulk insert with ? directly like query
                // So we loop or build query string. Looping is safer for prepared statements.
                for (const id of interestIds) {
                    await connection.execute(
                        'INSERT INTO user_interests (user_id, interest_id) VALUES (?, ?)',
                        [userId, id]
                    );
                }
            }
        }

        // 2. Update Sub-Interests
        if (subInterestIds) {
            // Clear existing
            await connection.execute('DELETE FROM user_sub_interests WHERE user_id = ?', [userId]);

            // Insert new
            if (subInterestIds.length > 0) {
                for (const id of subInterestIds) {
                    await connection.execute(
                        'INSERT INTO user_sub_interests (user_id, sub_interest_id) VALUES (?, ?)',
                        [userId, id]
                    );
                }
            }
        }

        await connection.commit();
        res.json({ msg: 'Interests updated successfully' });

    } catch (err) {
        await connection.rollback();
        console.error(err.message);
        res.status(500).send('Server Error');
    } finally {
        connection.release();
    }
};
