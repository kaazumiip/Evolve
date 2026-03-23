const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const auth = require('../middleware/authMiddleware');

// @route   GET api/chat/conversations
// @desc    Get all conversations
// @access  Private
router.get('/conversations', auth, chatController.getConversations);

// @route   POST api/chat/conversations
// @desc    Start a conversation
// @access  Private
router.post('/conversations', auth, chatController.startConversation);

// @route   GET api/chat/conversations/:id/messages
// @desc    Get messages for a conversation
// @access  Private
router.get('/conversations/:id/messages', auth, chatController.getMessages);

// @route   POST api/chat/conversations/:id/messages
// @desc    Send a message
// @access  Private
router.post('/conversations/:id/messages', auth, chatController.sendMessage);

// @route   PUT api/chat/messages/:id
// @desc    Edit a message
// @access  Private
router.put('/messages/:id', auth, chatController.editMessage);

// @route   DELETE api/chat/messages/:id
// @desc    Delete a message
// @access  Private
router.delete('/messages/:id', auth, chatController.deleteMessage);

// @route   POST api/chat/handle-stranger
// @desc    Accept or reject stranger chat
// @access  Private
router.post('/handle-stranger', auth, chatController.handleStrangerChat);

module.exports = router;
