const express = require('express');
const router = express.Router();
const FeedLike = require('../models/FeedLike');
const FeedPost = require('../models/FeedPost');
const auth = require('../middleware/auth');

// Get like count for a post
router.get('/posts/:postId/likes/count', async (req, res) => {
  try {
    const { postId } = req.params;
    
    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    // For identification posts, use the likes field
    if (post.type === 'identification') {
      return res.json({ likes: post.likes });
    }
    
    // For other posts, count from FeedLike collection
    const likeCount = await FeedLike.getLikeCount(postId);
    res.json({ likes: likeCount });
  } catch (error) {
    console.error('Error getting like count:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Check if user liked a post
router.get('/posts/:postId/likes/user/:userId', auth, async (req, res) => {
  try {
    const { postId, userId } = req.params;
    
    // Only check for non-identification posts
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    if (post.type === 'identification') {
      return res.json({ liked: false }); // Identification posts use simple likes counter
    }
    
    const isLiked = await FeedLike.isUserLiked(postId, userId);
    res.json({ liked: isLiked });
  } catch (error) {
    console.error('Error checking user like:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Toggle like/unlike a post
router.post('/posts/:postId/likes', auth, async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.id; // Get from auth middleware
    
    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    // For identification posts, increment/decrement the likes counter
    if (post.type === 'identification') {
      post.likes += 1;
      await post.save();
      return res.json({ 
        liked: true, 
        action: 'liked',
        likes: post.likes 
      });
    }
    
    // For other posts, use FeedLike model
    const result = await FeedLike.toggleLike(postId, userId);
    
    // Update the post's comment count if needed
    const likeCount = await FeedLike.getLikeCount(postId);
    
    res.json({ 
      ...result,
      likes: likeCount
    });
  } catch (error) {
    console.error('Error toggling like:', error);
    
    // Handle duplicate key error (user already liked)
    if (error.code === 11000) {
      return res.status(400).json({ message: 'You have already liked this post' });
    }
    
    res.status(500).json({ message: 'Server error' });
  }
});

// Unlike a post (for identification posts)
router.delete('/posts/:postId/likes', auth, async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.id;
    
    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    // Only for identification posts
    if (post.type === 'identification' && post.likes > 0) {
      post.likes -= 1;
      await post.save();
      return res.json({ 
        liked: false, 
        action: 'unliked',
        likes: post.likes 
      });
    }
    
    res.status(400).json({ message: 'Cannot unlike this post type' });
  } catch (error) {
    console.error('Error unliking post:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all users who liked a post (admin only)
router.get('/posts/:postId/likes', auth, async (req, res) => {
  try {
    const { postId } = req.params;
    
    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    // For identification posts, just return the count
    if (post.type === 'identification') {
      return res.json({ 
        likes: post.likes,
        users: [] // Don't return user list for identification posts
      });
    }
    
    const likes = await FeedLike.find({ postId })
      .populate('userId', 'username email')
      .sort({ createdAt: -1 });
    
    res.json({ 
      likes: likes.length,
      users: likes
    });
  } catch (error) {
    console.error('Error getting post likes:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
