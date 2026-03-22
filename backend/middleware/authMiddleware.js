const jwt = require('jsonwebtoken');
const db = require('../config/db');

module.exports = async function (req, res, next) {
    // Get token from header
    let token = req.header('x-auth-token');

    // Check for Authorization: Bearer <token>
    if (!token && req.header('Authorization')) {
        const authHeader = req.header('Authorization');
        if (authHeader.startsWith('Bearer ')) {
            token = authHeader.substring(7, authHeader.length);
        }
    }

    // Check if not token
    if (!token) {
        return res.status(401).json({ msg: 'No token, authorization denied' });
    }

    // Verify token
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded.user;
        console.log('--- Current User ID:', req.user.id);

        // Update last_seen asynchronously (don't block the request)
        db.query('UPDATE users SET last_seen = NOW() WHERE id = ?', [req.user.id])
            .catch(err => console.error('Error updating last_seen:', err));

        next();
    } catch (err) {
        res.status(401).json({ msg: 'Token is not valid' });
    }
};
