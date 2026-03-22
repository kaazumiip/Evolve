const db = require('../config/db');

exports.toggleFavorite = async (req, res) => {
    try {
        const { userId, itemType, itemId } = req.body;

        if (!userId || !itemType || !itemId) {
            console.error("Toggle Favorite Error: Missing params", { userId, itemType, itemId });
            return res.status(400).json({ message: "userId, itemType, and itemId are required." });
        }

        console.log(`Toggling Favorite -> User: ${userId}, Type: ${itemType}, Item: ${itemId}`);

        // Check if it already exists
        const checkQuery = `SELECT * FROM favorites WHERE user_id = ? AND item_type = ? AND item_id = ?`;
        const [result] = await db.execute(checkQuery, [userId, itemType, itemId]);

        if (result && result.length > 0) {
            // Delete it
            const deleteQuery = `DELETE FROM favorites WHERE user_id = ? AND item_type = ? AND item_id = ?`;
            await db.execute(deleteQuery, [userId, itemType, itemId]);
            return res.json({ message: "Favorite removed", isFavorited: false });
        } else {
            // Insert it
            const insertQuery = `INSERT INTO favorites (user_id, item_type, item_id) VALUES (?, ?, ?)`;
            await db.execute(insertQuery, [userId, itemType, itemId]);

            // Attempt to resolve the title for activity feed
            let title = `${itemType} #${itemId}`;
            if (itemType === 'scholarship') {
                try {
                    const [sResult] = await db.execute('SELECT title FROM scholarships WHERE id = ?', [itemId]);
                    if (sResult && sResult.length > 0) title = sResult[0].title;
                } catch (e) { }
            } else if (itemType === 'post') {
                try {
                    const [pResult] = await db.execute('SELECT title FROM posts WHERE id = ?', [itemId]);
                    if (pResult && pResult.length > 0) title = pResult[0].title;
                } catch (e) { }
            }

            await db.execute(
                'INSERT INTO activities (user_id, action_type, entity_title) VALUES (?, ?, ?)',
                [userId, 'favorited_item', title]
            );

            return res.json({ message: "Favorite added", isFavorited: true });
        }
    } catch (error) {
        console.error("Toggle Favorite Error:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

exports.getFavorites = async (req, res) => {
    try {
        const { userId } = req.params;
        if (!userId) {
            return res.status(400).json({ message: "userId is required." });
        }

        // We fetch the raw favorites first
        const favQuery = `SELECT * FROM favorites WHERE user_id = ? ORDER BY created_at DESC`;
        const [favorites] = await db.execute(favQuery, [userId]);
        console.log(`Fetched ${favorites.length} raw favorites for user ${userId}`);

        const populatedFavorites = [];

        // Concurrently populate the actual items securely
        await Promise.all(favorites.map(async (fav) => {
            if (fav.item_type === 'scholarship') {
                const sQuery = `SELECT * FROM scholarships WHERE id = ?`;
                const [sRes] = await db.execute(sQuery, [fav.item_id]);
                if (sRes && sRes.length > 0) {
                    const s = sRes[0];
                    s.isFavorite = true;
                    s.favorite_id = fav.id;
                    s.saved_type = 'scholarship';
                    // Parse necessary JSON for Flutter mapping
                    try { s.requirements = s.requirements ? JSON.parse(s.requirements) : []; } catch (e) { }
                    try { s.processes = s.processes ? JSON.parse(s.processes) : []; } catch (e) { }
                    try { s.quickFacts = s.quickFacts ? JSON.parse(s.quickFacts) : null; } catch (e) { }
                    try { s.providerDetails = s.providerDetails ? JSON.parse(s.providerDetails) : null; } catch (e) { }
                    try { s.checklist = s.checklist ? JSON.parse(s.checklist) : []; } catch (e) { }
                    populatedFavorites.push(s);
                }
            } else if (fav.item_type === 'post') {
                // Not fully using all community post joins here to keep bandwidth low, 
                // just fetching the main post core for preview.
                const pQuery = `SELECT p.*, u.name as author_name, u.email as author_email FROM posts p LEFT JOIN users u ON p.user_id = u.id WHERE p.id = ?`;
                const [pRes] = await db.execute(pQuery, [fav.item_id]);
                if (pRes && pRes.length > 0) {
                    const p = pRes[0];
                    p.isFavorite = true;
                    p.favorite_id = fav.id;
                    p.saved_type = 'post';
                    populatedFavorites.push(p);
                }
            }
        }));

        res.json(populatedFavorites);
    } catch (error) {
        console.error("Get Favorites Error:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};

exports.checkFavorite = async (req, res) => {
    try {
        const { userId, itemType, itemId } = req.query;
        if (!userId || !itemType || !itemId) {
            return res.status(400).json({ message: "userId, itemType, and itemId are required." });
        }

        const query = `SELECT id FROM favorites WHERE user_id = ? AND item_type = ? AND item_id = ?`;
        const [result] = await db.execute(query, [userId, itemType, itemId]);

        res.json({ isFavorited: result && result.length > 0 });
    } catch (error) {
        console.error("Check Favorite Error:", error);
        res.status(500).json({ message: "Internal server error" });
    }
};
