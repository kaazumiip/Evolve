const express = require('express');
const router = express.Router();
const interestController = require('../controllers/interestController');
const auth = require('../middleware/authMiddleware'); // Assuming you have auth middleware

// @route   GET api/interests
// @desc    Get all interests and sub-interests
// @access  Public (or Private depending on needs, usually Public for picker)
router.get('/', interestController.getAllInterests);

// @route   POST api/interests/user
// @desc    Save user selected interests and sub-interests
// @access  Private
router.post('/user', auth, interestController.saveUserInterests);

module.exports = router;
