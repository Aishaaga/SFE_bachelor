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
    
    // Use FeedLike model for accurate counts for all post types
    console.log('DEBUG: Getting like count for post:', postId, 'type:', post.type);
    
    const likeCount = await FeedLike.getLikeCount(postId);
    
    // Update the post's likes field for consistency
    post.likes = likeCount;
    await post.save();
    
    console.log('DEBUG: Like count from FeedLike:', likeCount);
    
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
    
    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    // Use FeedLike model for all post types
    console.log('DEBUG: Checking if user liked - postId:', postId, 'userId:', userId);
    
    const isLiked = await FeedLike.isUserLiked(postId, userId);
    
    console.log('DEBUG: User liked status:', isLiked);
    
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
    const userId = req.userId; // Get from auth middleware
    
    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    // Use FeedLike model for all post types to prevent multiple likes per user
    console.log('DEBUG: Toggling like - postId:', postId, 'userId:', userId, 'postType:', post.type);
    
    // Check if user already liked this post
    const existingLike = await FeedLike.findOne({
      feedPostId: postId,
      userId: userId
    });
    
    let result;
    if (existingLike) {
      // Unlike the post
      await FeedLike.deleteOne({ _id: existingLike._id });
      result = { liked: false, action: 'unliked' };
      console.log('DEBUG: Post unliked');
    } else {
      // Like the post
      await FeedLike.create({
        feedPostId: postId,
        userId: userId
      });
      result = { liked: true, action: 'liked' };
      console.log('DEBUG: Post liked');
    }
    
    // Get accurate like count
    const likeCount = await FeedLike.getLikeCount(postId);
    
    // Update the post's likes field for consistency (for all post types)
    post.likes = likeCount;
    await post.save();
    
    console.log('DEBUG: Updated like count:', likeCount);
    
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
