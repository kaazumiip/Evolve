const express = require('express');
const router = express.Router();
const communityController = require('../controllers/communityController');
const auth = require('../middleware/authMiddleware');

// @route   GET api/community/posts
// @desc    Get all posts
// @access  Private
router.get('/posts', auth, communityController.getAllPosts);

// @route   POST api/community/posts
// @desc    Create a post
// @access  Private
router.post('/posts', auth, communityController.createPost);

// @route   GET api/community/users/search
// @desc    Search users
// @access  Private
router.get('/users/search', auth, communityController.searchUsers);

// @route   GET api/community/posts/search
// @desc    Search posts
// @access  Private
router.get('/posts/search', auth, communityController.searchPosts);

// @route   GET api/community/tags/search
// @desc    Search by tag
// @access  Private
router.get('/tags/search', auth, communityController.searchByTag);

// @route   GET api/community/posts/:id
// @desc    Get post details
// @access  Private
router.get('/posts/:id', auth, communityController.getPostDetails);

// @route   PUT api/community/posts/:id
// @desc    Update a post
// @access  Private
router.put('/posts/:id', auth, communityController.updatePost);

// @route   DELETE api/community/posts/:id
// @desc    Delete a post
// @access  Private
router.delete('/posts/:id', auth, communityController.deletePost);

// @route   POST api/community/posts/:id/comments
// @desc    Add a comment
// @access  Private
router.post('/posts/:id/comments', auth, communityController.addComment);

// @route   POST api/community/posts/:id/like
// @desc    Toggle like
// @access  Private
router.post('/posts/:id/like', auth, communityController.toggleLike);

// @route   POST api/community/comments/:id/like
// @desc    Toggle like on a comment
// @access  Private
router.post('/comments/:id/like', auth, communityController.toggleCommentLike);


// @route   GET api/community/recommendations
// @desc    Get recommended users
// @access  Private
router.get('/recommendations', auth, communityController.getRecommendations);

// @route   GET api/community/users/:id/activities
// @desc    Get user recent activities
// @access  Private
router.get('/users/:id/activities', auth, communityController.getUserActivities);

module.exports = router;
