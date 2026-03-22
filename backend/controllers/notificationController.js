const db = require('../config/db');

// Fetch notifications for the logged-in user
exports.getNotifications = async (req, res) => {
    try {
        const userId = req.user.id;

        // Fetch notifications and join with sender details
        const [notifications] = await db.execute(`
            SELECT 
                n.*, 
                u.name as senderName, 
                u.profile_picture as senderImage
            FROM notifications n
            JOIN users u ON n.sender_id = u.id
            WHERE n.user_id = ?
            ORDER BY n.created_at DESC
        `, [userId]);

        res.json(notifications);
    } catch (err) {
        console.error('Error fetching notifications:', err.message);
        res.status(500).send('Server Error');
    }
};

// Mark a specific notification as read
exports.markAsRead = async (req, res) => {
    try {
        const notificationId = req.params.id;
        const userId = req.user.id;

        await db.execute(
            'UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?',
            [notificationId, userId]
        );

        res.json({ msg: 'Notification marked as read' });
    } catch (err) {
        console.error('Error marking notification read:', err.message);
        res.status(500).send('Server Error');
    }
};

// Mark all notifications as read for the user
exports.markAllAsRead = async (req, res) => {
    try {
        const userId = req.user.id;

        await db.execute(
            'UPDATE notifications SET is_read = 1 WHERE user_id = ?',
            [userId]
        );

        res.json({ msg: 'All notifications marked as read' });
    } catch (err) {
        console.error('Error marking all notifications read:', err.message);
        res.status(500).send('Server Error');
    }
};
