const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const auth = require('../middleware/authMiddleware');
const multer = require('multer');
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// @route   POST api/upload
// @desc    Upload media to Cloudinary
// @access  Private
router.post('/', [auth, upload.single('image')], uploadController.uploadMedia);

module.exports = router;
