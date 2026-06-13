const express = require('express');
const router = express.Router();
const FeedComment = require('../models/FeedComment');
const FeedPost = require('../models/FeedPost');
const auth = require('../middleware/auth');

// Get comments for a post with pagination
router.get('/posts/:postId/comments', async (req, res) => {
  try {
    const { postId } = req.params;
    const { page = 1, limit = 20, sortBy = 'createdAt', sortOrder = 'asc' } = req.query;
    
    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    const options = {
      page: parseInt(page),
      limit: parseInt(limit),
      sortBy,
      sortOrder
    };
    
    const comments = await FeedComment.getPostComments(postId, options);
    const totalComments = await FeedComment.getCommentCount(postId);
    
    res.json({
      comments,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: totalComments,
        pages: Math.ceil(totalComments / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Error getting comments:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get comment count for a post
router.get('/posts/:postId/comments/count', async (req, res) => {
  try {
    const { postId } = req.params;
    
    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    const commentCount = await FeedComment.getCommentCount(postId);
    res.json({ comments: commentCount });
  } catch (error) {
    console.error('Error getting comment count:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Add a comment to a post
router.post('/posts/:postId/comments', auth, async (req, res) => {
  try {
    const { postId } = req.params;
    const { content, parentId = null, isAnonymous = false } = req.body;
    const userId = req.userId;

    // Validate content
    if (!content || content.trim().length === 0) {
      return res.status(400).json({ message: 'Comment content is required' });
    }

    if (content.length > 1000) {
      return res.status(400).json({ message: 'Comment too long (max 1000 characters)' });
    }

    // Check if post exists
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // If parentId is provided, check if parent comment exists
    if (parentId) {
      const parentComment = await FeedComment.findById(parentId);
      if (!parentComment || parentComment.feedPostId.toString() !== postId) {
        return res.status(404).json({ message: 'Parent comment not found' });
      }
    }

    // Create comment
    const commentData = {
      feedPostId: postId,
      userId,
      content: content.trim(),
      parentId,
      isAnonymous: isAnonymous === true
    };

    // Generate random anonymous ID if anonymous
    if (isAnonymous === true) {
      commentData.anonymousId = Math.floor(Math.random() * 9000) + 1000; // 4-digit random number
    }

    const comment = await FeedComment.create(commentData);

    // Populate user data (only if not anonymous)
    if (isAnonymous !== true) {
      await comment.populate('userId', 'name email profileImage');
    }

    // Update post's comment count
    const commentCount = await FeedComment.getCommentCount(postId);

    // Update the post's commentCount field
    post.commentCount = commentCount;
    await post.save();

    // Convert to plain object to ensure all fields are included
    const commentObj = comment.toObject();
    if (isAnonymous === true) {
      commentObj.userId = undefined;
    }

    res.status(201).json({
      comment: commentObj,
      commentCount
    });
  } catch (error) {
    console.error('Error adding comment:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Edit a comment
router.put('/comments/:commentId', auth, async (req, res) => {
  try {
    const { commentId } = req.params;
    const { content } = req.body;
    const userId = req.userId;
    
    // Validate content
    if (!content || content.trim().length === 0) {
      return res.status(400).json({ message: 'Comment content is required' });
    }
    
    if (content.length > 1000) {
      return res.status(400).json({ message: 'Comment too long (max 1000 characters)' });
    }
    
    // Find comment and check ownership
    const comment = await FeedComment.findById(commentId);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }
    
    if (comment.userId.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized to edit this comment' });
    }
    
    // Edit comment
    await comment.editContent(content.trim());
    await comment.populate('userId', 'name email profileImage');

    // Convert to plain object and handle anonymous comments
    const commentObj = comment.toObject();
    if (commentObj.isAnonymous === true) {
      commentObj.userId = undefined;
    }

    res.json(commentObj);
  } catch (error) {
    console.error('Error editing comment:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete a comment (soft delete)
router.delete('/comments/:commentId', auth, async (req, res) => {
  try {
    const { commentId } = req.params;
    const userId = req.userId;

    // Find comment and check ownership
    const comment = await FeedComment.findById(commentId);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    // Prevent deletion of anonymous comments
    if (comment.isAnonymous === true) {
      return res.status(403).json({ message: 'Cannot delete anonymous comments' });
    }

    if (comment.userId.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized to delete this comment' });
    }

    // Soft delete comment
    await comment.softDelete();

    // Update post's comment count
    const commentCount = await FeedComment.getCommentCount(comment.feedPostId);

    // Update the post's commentCount field
    const post = await FeedPost.findById(comment.feedPostId);
    if (post) {
      post.commentCount = commentCount;
      await post.save();
    }

    res.json({
      message: 'Comment deleted successfully',
      commentCount
    });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get replies to a comment
router.get('/comments/:commentId/replies', async (req, res) => {
  try {
    const { commentId } = req.params;
    
    // Check if parent comment exists
    const parentComment = await FeedComment.findById(commentId);
    if (!parentComment) {
      return res.status(404).json({ message: 'Comment not found' });
    }
    
    const replies = await FeedComment.getReplies(commentId);
    
    res.json({ replies });
  } catch (error) {
    console.error('Error getting replies:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get a single comment
router.get('/comments/:commentId', async (req, res) => {
  try {
    const { commentId } = req.params;

    const comment = await FeedComment.findById(commentId)
      .populate('userId', 'name email profileImage')
      .populate('parentId', 'content userId');

    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    // Convert to plain object and handle anonymous comments
    const commentObj = comment.toObject();
    if (commentObj.isAnonymous === true) {
      commentObj.userId = undefined;
    }

    res.json(commentObj);
  } catch (error) {
    console.error('Error getting comment:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
