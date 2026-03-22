const express = require('express');
const router = express.Router();
const scholarshipController = require('../controllers/scholarshipController');
const auth = require('../middleware/authMiddleware');

// GET /api/scholarships/scout
router.get('/scout', scholarshipController.scoutScholarships);

// POST /api/scholarships/view
router.post('/view', auth, scholarshipController.logView);

module.exports = router;
