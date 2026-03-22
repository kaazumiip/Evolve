const express = require('express');
const router = express.Router();
const careerController = require('../controllers/careerController');

router.post('/compare', careerController.generateCareerComparison);
router.post('/roadmap', careerController.generateCareerRoadmap);

module.exports = router;
