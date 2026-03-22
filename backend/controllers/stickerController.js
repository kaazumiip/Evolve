const db = require('../config/db');
const cloudinary = require('cloudinary').v2;

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

exports.createSticker = async (req, res) => {
    try {
        const { name, is_public } = req.body;
        const userId = req.user.id;

        if (!req.file) {
            return res.status(400).json({ msg: 'No sticker image provided' });
        }

        // Upload to Cloudinary
        const uploadResult = await new Promise((resolve, reject) => {
            const uploadStream = cloudinary.uploader.upload_stream(
                {
                    folder: 'evolve_stickers',
                    resource_type: 'image',
                    // Background removal could be done here if we had the Cloudinary add-on,
                    // but for now we assume the client sends the processed image (PNG with transparency).
                },
                (error, result) => {
                    if (error) reject(error);
                    else resolve(result);
                }
            );
            uploadStream.end(req.file.buffer);
        });

        const imageUrl = uploadResult.secure_url;

        // Save to DB
        const [result] = await db.execute(
            'INSERT INTO stickers (user_id, name, image_url, is_public) VALUES (?, ?, ?, ?)',
            [userId, name, imageUrl, is_public === 'true' || is_public === true ? 1 : 0]
        );

        res.status(201).json({
            id: result.insertId,
            name,
            image_url: imageUrl,
            is_public: !!is_public
        });

    } catch (err) {
        console.error('Create Sticker Error:', err.message);
        res.status(500).send('Server Error');
    }
};

exports.getPublicStickers = async (req, res) => {
    try {
        const [stickers] = await db.execute(
            'SELECT s.*, u.name as creator_name FROM stickers s JOIN users u ON s.user_id = u.id WHERE s.is_public = 1 ORDER BY s.created_at DESC'
        );
        res.json(stickers);
    } catch (err) {
        console.error('Get Public Stickers Error:', err.message);
        res.status(500).send('Server Error');
    }
};

exports.getMyStickers = async (req, res) => {
    try {
        const userId = req.user.id;
        const [stickers] = await db.execute(
            'SELECT * FROM stickers WHERE user_id = ? ORDER BY created_at DESC',
            [userId]
        );
        res.json(stickers);
    } catch (err) {
        console.error('Get My Stickers Error:', err.message);
        res.status(500).send('Server Error');
    }
};

exports.searchStickers = async (req, res) => {
    try {
        const { q } = req.query;
        if (!q) return res.json([]);

        const [stickers] = await db.execute(
            'SELECT s.*, u.name as creator_name FROM stickers s JOIN users u ON s.user_id = u.id WHERE s.is_public = 1 AND s.name LIKE ? ORDER BY s.created_at DESC',
            [`%${q}%`]
        );
        res.json(stickers);
    } catch (err) {
        console.error('Search Stickers Error:', err.message);
        res.status(500).send('Server Error');
    }
};
