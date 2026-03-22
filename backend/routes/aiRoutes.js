const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const authMiddleware = require('../middleware/authMiddleware');

// @route   POST api/ai/chat
// @desc    Get AI Response from OpenRouter
// @access  Private (Needs Token)
router.post('/chat', authMiddleware, aiController.getAIResponse);

module.exports = router;
