const express = require('express');
const router = express.Router();
const stickerController = require('../controllers/stickerController');
const auth = require('../middleware/authMiddleware');
const multer = require('multer');
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// @route   POST api/stickers
// @desc    Create a new sticker
// @access  Private
router.post('/', [auth, upload.single('image')], stickerController.createSticker);

// @route   GET api/stickers
// @desc    Get all public stickers
// @access  Public
router.get('/', stickerController.getPublicStickers);

// @route   GET api/stickers/my
// @desc    Get current user's stickers
// @access  Private
router.get('/my', auth, stickerController.getMyStickers);

// @route   GET api/stickers/search
// @desc    Search public stickers
// @access  Public
router.get('/search', stickerController.searchStickers);

module.exports = router;
