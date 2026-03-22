const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/authMiddleware');
const passport = require('passport')

// @route   POST api/auth/register
// @desc    Register user
// @access  Public
router.post('/register', authController.register);

// @route   POST api/auth/login
// @desc    Login user
// @access  Public
router.post('/login', authController.login);

// @route   POST api/auth/google/native
// @desc    Google Native Login
// @access  Public
router.post('/google/native', authController.googleNativeLogin);

// @route   POST api/auth/facebook
// @desc    Facebook Login
// @access  Public
router.post('/facebook', authController.facebookLogin);

// OTP & Password Reset
router.post('/send-otp', authController.sendOTP);
router.post('/verify-otp', authController.verifyOTP);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);



// @route   GET api/auth/me
// @desc    Get current user
// @access  Private
router.get('/google', passport.authenticate('google', { scope: ['profile', 'email'] }))
router.put('/me', authMiddleware, authController.updateProfile);
router.get('/me', authMiddleware, authController.getMe);

router.get('/google/callback', passport.authenticate('google', { failureRedirect: '/login' }), (req, res) => {
    // Generate token
    const token = authController.generateToken(req.user.id);
    // Redirect to app with token
    res.redirect(`evolve://auth_callback?token=${token}`);
})

const multer = require('multer');
const path = require('path');

// Configure Multer for memory storage
const storage = multer.memoryStorage();

const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png/;
        const mimetype = filetypes.test(file.mimetype);
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
        if (mimetype && extname) {
            return cb(null, true);
        }
        cb(new Error('Only images are allowed'));
    }
});

// @route   POST api/auth/upload-profile-picture
// @desc    Upload profile picture
// @access  Private
router.post('/upload-profile-picture', authMiddleware, upload.single('image'), authController.uploadProfilePicture);

// @route   POST api/auth/change-password
// @desc    Change user password
// @access  Private
router.post('/change-password', authMiddleware, authController.changePassword);

// @route   POST api/auth/update-fcm-token
// @desc    Update FCM token
// @access  Private
router.post('/update-fcm-token', authMiddleware, authController.updateFcmToken);

module.exports = router;
