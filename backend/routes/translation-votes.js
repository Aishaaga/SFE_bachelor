const express = require('express');
const router = express.Router();
const TranslationVote = require('../models/TranslationVote');
const FeedPost = require('../models/FeedPost');
const auth = require('../middleware/auth');

// Get vote counts for a feed post (translation suggestion type)
router.get('/posts/:postId/votes', async (req, res) => {
  try {
    const { postId } = req.params;
    
    // Check if post exists and is a translation suggestion
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    if (post.type !== 'translation_suggestion') {
      return res.status(400).json({ message: 'Post is not a translation suggestion' });
    }
    
    // Use TranslationVote model for accurate counts
    console.log('DEBUG: Getting votes for post:', postId);
    
    const upvotes = await TranslationVote.countDocuments({
      translationSuggestionId: postId,
      voteType: 'upvote'
    });
    const downvotes = await TranslationVote.countDocuments({
      translationSuggestionId: postId,
      voteType: 'downvote'
    });
    
    const voteCounts = {
      upvotes,
      downvotes,
      total: upvotes + downvotes
    };
    
    console.log('DEBUG: Vote counts from TranslationVote:', voteCounts);
    
    // Also update the post's vote counts for consistency
    post.upvotes = upvotes;
    post.downvotes = downvotes;
    await post.save();
    
    res.json(voteCounts);
  } catch (error) {
    console.error('Error getting vote counts:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get a user's vote on a translation suggestion
router.get('/suggestions/:suggestionId/votes/user/:userId', auth, async (req, res) => {
  try {
    const { suggestionId, userId } = req.params;
    
    // Check if suggestion exists
    const suggestion = await TranslationSuggestion.findById(suggestionId);
    if (!suggestion) {
      return res.status(404).json({ message: 'Translation suggestion not found' });
    }
    
    const userVote = await TranslationVote.getUserVote(suggestionId, userId);
    
    if (!userVote) {
      return res.json({ voted: false });
    }
    
    res.json({ 
      voted: true,
      vote: userVote
    });
  } catch (error) {
    console.error('Error getting user vote:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Cast or update a vote on a feed post (translation suggestion)
router.post('/posts/:postId/votes', auth, async (req, res) => {
  try {
    const { postId } = req.params;
    const { voteType, reason } = req.body;
    const userId = req.userId;
    
    // Validate voteType
    if (!['upvote', 'downvote'].includes(voteType)) {
      return res.status(400).json({ message: 'Invalid vote type. Must be upvote or downvote' });
    }
    
    // Validate reason length
    if (reason && reason.length > 500) {
      return res.status(400).json({ message: 'Reason too long (max 500 characters)' });
    }
    
    // Check if post exists and is a translation suggestion
    const post = await FeedPost.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    
    if (post.type !== 'translation_suggestion') {
      return res.status(400).json({ message: 'Post is not a translation suggestion' });
    }
    
    // Use TranslationVote model for proper tracking
    console.log('DEBUG: Casting vote - postId:', postId, 'userId:', userId, 'voteType:', voteType);
    
    // Check if user has already voted
    const existingVote = await TranslationVote.findOne({
      translationSuggestionId: postId,
      userId: userId
    });
    
    let voteCounts;
    if (existingVote) {
      // Update existing vote
      const previousVoteType = existingVote.voteType;
      existingVote.voteType = voteType;
      existingVote.updatedAt = new Date();
      await existingVote.save();
      
      // Recalculate vote counts
      const upvotes = await TranslationVote.countDocuments({
        translationSuggestionId: postId,
        voteType: 'upvote'
      });
      const downvotes = await TranslationVote.countDocuments({
        translationSuggestionId: postId,
        voteType: 'downvote'
      });
      
      voteCounts = { upvotes, downvotes, total: upvotes + downvotes };
      
      // Update the post's vote counts for display
      post.upvotes = upvotes;
      post.downvotes = downvotes;
      await post.save();
      
      console.log('DEBUG: Vote updated - from', previousVoteType, 'to', voteType);
    } else {
      // Create new vote
      await TranslationVote.create({
        translationSuggestionId: postId,
        userId: userId,
        voteType: voteType
      });
      
      // Recalculate vote counts
      const upvotes = await TranslationVote.countDocuments({
        translationSuggestionId: postId,
        voteType: 'upvote'
      });
      const downvotes = await TranslationVote.countDocuments({
        translationSuggestionId: postId,
        voteType: 'downvote'
      });
      
      voteCounts = { upvotes, downvotes, total: upvotes + downvotes };
      
      // Update the post's vote counts for display
      post.upvotes = upvotes;
      post.downvotes = downvotes;
      await post.save();
      
      console.log('DEBUG: New vote created');
    }
    
    console.log('DEBUG: Final vote counts:', voteCounts);
    
    res.status(201).json({
      success: true,
      message: 'Vote recorded successfully',
      action: existingVote ? 'updated' : 'created',
      voteCounts: voteCounts
    });
  } catch (error) {
    console.error('Error casting vote:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update a vote (change vote type or reason)
router.put('/suggestions/:suggestionId/votes', auth, async (req, res) => {
  try {
    const { suggestionId } = req.params;
    const { voteType, reason } = req.body;
    const userId = req.userId;
    
    // Validate voteType
    if (!['upvote', 'downvote'].includes(voteType)) {
      return res.status(400).json({ message: 'Invalid vote type. Must be upvote or downvote' });
    }
    
    // Validate reason length
    if (reason && reason.length > 500) {
      return res.status(400).json({ message: 'Reason too long (max 500 characters)' });
    }
    
    // Check if suggestion exists
    const suggestion = await TranslationSuggestion.findById(suggestionId);
    if (!suggestion) {
      return res.status(404).json({ message: 'Translation suggestion not found' });
    }
    
    // Update vote
    const result = await TranslationVote.castVote(suggestionId, userId, voteType, reason);
    
    // Get updated vote counts
    const voteCounts = await TranslationVote.getVoteCounts(suggestionId);
    
    res.json({
      ...result,
      voteCounts
    });
  } catch (error) {
    console.error('Error updating vote:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Remove a vote
router.delete('/suggestions/:suggestionId/votes', auth, async (req, res) => {
  try {
    const { suggestionId } = req.params;
    const userId = req.userId;
    
    // Check if suggestion exists
    const suggestion = await TranslationSuggestion.findById(suggestionId);
    if (!suggestion) {
      return res.status(404).json({ message: 'Translation suggestion not found' });
    }
    
    // Remove vote
    const result = await TranslationVote.removeVote(suggestionId, userId);
    
    // Get updated vote counts
    const voteCounts = await TranslationVote.getVoteCounts(suggestionId);
    
    res.json({
      ...result,
      voteCounts
    });
  } catch (error) {
    console.error('Error removing vote:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all votes for a translation suggestion (admin only)
router.get('/suggestions/:suggestionId/votes/all', auth, async (req, res) => {
  try {
    const { suggestionId } = req.params;
    
    // Check if suggestion exists
    const suggestion = await TranslationSuggestion.findById(suggestionId);
    if (!suggestion) {
      return res.status(404).json({ message: 'Translation suggestion not found' });
    }
    
    const votes = await TranslationVote.find({ translationSuggestionId: suggestionId })
      .populate('userId', 'username email')
      .sort({ createdAt: -1 });
    
    res.json({ votes });
  } catch (error) {
    console.error('Error getting all votes:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get batch vote counts for multiple suggestions
router.post('/suggestions/batch/votes', async (req, res) => {
  try {
    const { suggestionIds } = req.body;
    
    if (!Array.isArray(suggestionIds) || suggestionIds.length === 0) {
      return res.status(400).json({ message: 'Invalid suggestion IDs array' });
    }
    
    const voteMap = await TranslationVote.getBatchVoteCounts(suggestionIds);
    
    res.json(voteMap);
  } catch (error) {
    console.error('Error getting batch vote counts:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get vote statistics for a suggestion
router.get('/suggestions/:suggestionId/votes/stats', async (req, res) => {
  try {
    const { suggestionId } = req.params;
    
    // Check if suggestion exists
    const suggestion = await TranslationSuggestion.findById(suggestionId);
    if (!suggestion) {
      return res.status(404).json({ message: 'Translation suggestion not found' });
    }
    
    const voteCounts = await TranslationVote.getVoteCounts(suggestionId);
    
    // Calculate additional stats
    const totalVotes = voteCounts.upvotes + voteCounts.downvotes;
    const approvalRate = totalVotes > 0 ? (voteCounts.upvotes / totalVotes * 100).toFixed(1) : 0;
    
    res.json({
      ...voteCounts,
      approvalRate: parseFloat(approvalRate),
      totalVotes
    });
  } catch (error) {
    console.error('Error getting vote stats:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
