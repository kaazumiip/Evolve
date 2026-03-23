const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const auth = require('../middleware/authMiddleware');

// @route   GET /api/users/profile/:id
// @desc    Get user profile and friendship status
// @access  Private
router.get('/profile/:id', auth, userController.getUserProfile);

// @route   POST /api/users/friend-request/:id
// @desc    Send friend request
// @access  Private
router.post('/friend-request/:id', auth, userController.sendFriendRequest);

// @route   POST /api/users/friend-accept/:id
// @desc    Accept friend request
// @access  Private
router.post('/friend-accept/:id', auth, userController.acceptFriendRequest);

// @route   GET /api/users/search
// @desc    Search users by name or email
// @access  Private
router.get('/search', auth, userController.searchUsers);

// @route   DELETE /api/users/friend/:id
// @desc    Remove friend or cancel request
// @access  Private
router.delete('/friend/:id', auth, userController.removeFriend);

// @route   GET /api/users/friends
// @desc    Get current user's friend list
// @access  Private
router.get('/friends', auth, userController.getFriends);

// @route   GET /api/users/friends/:userId
// @desc    Get specific user's friend list
// @access  Private
router.get('/friends/:userId', auth, userController.getFriends);

// @route   PUT /api/users/subscription
// @desc    Update user subscription
// @access  Private
// @route   POST /api/users/block/:targetUserId
// @desc    Block a user
// @access  Private
router.post('/block/:targetUserId', auth, userController.blockUser);

// @route   POST /api/users/unblock/:targetUserId
// @desc    Unblock a user
// @access  Private
router.post('/unblock/:targetUserId', auth, userController.unblockUser);

// @route   POST /api/users/report/:targetUserId
// @desc    Report a user
// @access  Private
router.post('/report/:targetUserId', auth, userController.reportUser);

router.put('/subscription', auth, userController.updateSubscription);

module.exports = router;
