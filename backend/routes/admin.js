// Purpose: All admin API endpoints
// Location: sfe-backend/routes/admin.js

const express = require('express');
const router = express.Router();
const adminAuth = require('../middleware/adminAuth');
const auth = require('../middleware/auth'); // Regular auth first
const TranslationSuggestion = require('../models/TranslationSuggestion');
const FeedPost = require('../models/FeedPost');
const TranslationVote = require('../models/TranslationVote');
const User = require('../models/User');
const Identification = require('../models/Identification');
const ApprovedTranslation = require('../models/ApprovedTranslation');

// All admin routes require: first regular auth (user logged in), then admin check
// Apply both middlewares in order

// GET /api/admin/pending - Get all active translation suggestions with vote counts
router.get('/pending', auth, adminAuth, async (req, res) => {
  try {
    // Find all translation suggestions with status 'active' (visible for voting)
    const suggestions = await FeedPost.find({ 
      type: 'translation_suggestion',
      status: 'active'
    })
      .populate('userId', 'name email')
      .sort({ createdAt: -1 });
    
    // Get vote counts for all suggestions
    const suggestionIds = suggestions.map(s => s._id.toString());
    const voteMap = await TranslationVote.getBatchVoteCounts(suggestionIds);
    
    // Transform data for dashboard compatibility
    const transformedSuggestions = suggestions.map(s => ({
      _id: s._id,
      plantScientificName: s.scientificName,
      suggestedDarija: s.suggestedDarija,
      suggestedTamazight: s.suggestedTamazight,
      user: s.userId ? {
        name: s.userId.name,
        email: s.userId.email
      } : {
        name: 'Anonymous',
        email: ''
      },
      status: 'pending', // Map 'flagged' to 'pending' for dashboard
      submittedAt: s.createdAt,
      contributorName: s.userId ? s.userId.name : 'Anonymous',
      contributorEmail: s.userId ? s.userId.email : '',
      contributorRegion: s.location?.city || '',
      notes: s.notes || '',
      // Include vote counts
      upvotes: voteMap[s._id.toString()]?.upvotes || 0,
      downvotes: voteMap[s._id.toString()]?.downvotes || 0,
      totalVotes: voteMap[s._id.toString()]?.total || 0
    }));
    
    res.json({
      success: true,
      suggestions: transformedSuggestions
    });
    
  } catch (error) {
    console.error('Error fetching pending:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error fetching suggestions' 
    });
  }
});

// GET /api/admin/approved - Get approved suggestions
router.get('/approved', auth, adminAuth, async (req, res) => {
  try {
    const suggestions = await ApprovedTranslation.find({ status: 'active' })
      .populate('approvedBy', 'name email')
      .populate('suggestedBy', 'name email')
      .sort({ approvedAt: -1 });
    
    res.json({
      success: true,
      suggestions: suggestions
    });
    
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching approved' });
  }
});

// GET /api/admin/rejected - Get rejected suggestions
router.get('/rejected', auth, adminAuth, async (req, res) => {
  try {
    const suggestions = await TranslationSuggestion.find({ status: 'rejected' })
      .populate('user', 'name email')
      .sort({ reviewedAt: -1 });
    
    res.json({
      success: true,
      suggestions: suggestions
    });
    
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching rejected' });
  }
});

// POST /api/admin/approve/:id - Approve a suggestion
router.post('/approve/:id', auth, adminAuth, async (req, res) => {
  try {
    const suggestionId = req.params.id;
    const adminId = req.userId;
    
    // Find the suggestion in FeedPost
    const suggestion = await FeedPost.findById(suggestionId);
    
    if (!suggestion) {
      return res.status(404).json({ success: false, message: 'Suggestion not found' });
    }
    
    // Get vote counts for this suggestion
    const voteMap = await TranslationVote.getBatchVoteCounts([suggestionId]);
    const votes = voteMap[suggestionId] || { upvotes: 0, downvotes: 0, total: 0 };
    
    // Check if translation already exists for this plant
    const existingTranslation = await ApprovedTranslation.existsForPlant(suggestion.scientificName);
    if (existingTranslation) {
      return res.status(400).json({ 
        success: false, 
        message: 'An approved translation already exists for this plant' 
      });
    }
    
    // Create approved translation record
    const approvedTranslation = new ApprovedTranslation({
      scientificName: suggestion.scientificName,
      plantName: suggestion.plantName,
      darijaTranslation: suggestion.suggestedDarija,
      tamazightTranslation: suggestion.suggestedTamazight,
      suggestedBy: suggestion.userId,
      contributorName: suggestion.userId ? suggestion.userId.name : 'Anonymous',
      contributorEmail: suggestion.userId ? suggestion.userId.email : '',
      contributorRegion: suggestion.location?.city || '',
      approvedBy: adminId,
      approvedAt: new Date(),
      originalSuggestionId: suggestion._id,
      upvotesAtApproval: votes.upvotes,
      downvotesAtApproval: votes.downvotes,
      totalVotesAtApproval: votes.total,
      notes: suggestion.notes || '',
      status: 'active'
    });
    
    await approvedTranslation.save();
    
    // Update suggestion status to indicate it's been approved
    suggestion.status = 'active';
    suggestion.updatedAt = new Date();
    await suggestion.save();
    
    res.json({
      success: true,
      message: 'Translation approved and saved successfully',
      approvedTranslation: approvedTranslation
    });
    
  } catch (error) {
    console.error('Error approving:', error);
    res.status(500).json({ success: false, message: 'Error approving suggestion' });
  }
});

// POST /api/admin/reject/:id - Reject a suggestion
router.post('/reject/:id', auth, adminAuth, async (req, res) => {
  try {
    const suggestionId = req.params.id;
    const adminId = req.userId;
    const { reason } = req.body; // Optional rejection reason
    
    const suggestion = await FeedPost.findById(suggestionId);
    
    if (!suggestion) {
      return res.status(404).json({ success: false, message: 'Suggestion not found' });
    }
    
    suggestion.status = 'hidden'; // rejected = hidden
    suggestion.updatedAt = new Date();
    // Store rejection reason in notes field for now
    if (reason) {
      suggestion.notes = (suggestion.notes || '') + `\n\nRejection reason: ${reason}`;
    }
    
    await suggestion.save();
    
    res.json({
      success: true,
      message: 'Translation rejected'
    });
    
  } catch (error) {
    console.error('Error rejecting:', error);
    res.status(500).json({ success: false, message: 'Error rejecting suggestion' });
  }
});

// GET /api/admin/stats - Get dashboard statistics
router.get('/stats', auth, adminAuth, async (req, res) => {
  try {
    // Get counts of suggestions by status from FeedPost
    const pendingCount = await FeedPost.countDocuments({ 
      type: 'translation_suggestion', 
      status: 'active' 
    });
    const approvedCount = await ApprovedTranslation.countDocuments({ 
      status: 'active' 
    });
    const rejectedCount = await FeedPost.countDocuments({ 
      type: 'translation_suggestion', 
      status: 'hidden' 
    });
    
    // Get total users
    const totalUsers = await User.countDocuments();
    
    // Get total identifications
    const totalIdentifications = await Identification.countDocuments();
    
    // Get recent activity (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentSuggestions = await FeedPost.countDocuments({
      type: 'translation_suggestion',
      createdAt: { $gte: sevenDaysAgo }
    });
    
    res.json({
      success: true,
      stats: {
        pending: pendingCount,
        approved: approvedCount,
        rejected: rejectedCount,
        totalSuggestions: pendingCount + approvedCount + rejectedCount,
        totalUsers: totalUsers,
        totalIdentifications: totalIdentifications,
        recentSuggestions: recentSuggestions
      }
    });
    
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ success: false, message: 'Error fetching stats' });
  }
});

module.exports = router;