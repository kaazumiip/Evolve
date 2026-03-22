const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authMiddleware = require('../middleware/authMiddleware');

// Route to get all notifications for the authenticated user
router.get('/', authMiddleware, notificationController.getNotifications);

// Route to mark a single notification as read
router.post('/:id/read', authMiddleware, notificationController.markAsRead);

// Route to mark all notifications as read
router.post('/read-all', authMiddleware, notificationController.markAllAsRead);

module.exports = router;
