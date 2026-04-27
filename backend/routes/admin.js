// Purpose: All admin API endpoints
// Location: sfe-backend/routes/admin.js

const express = require('express');
const router = express.Router();
const adminAuth = require('../middleware/adminAuth');
const auth = require('../middleware/auth'); // Regular auth first
const TranslationSuggestion = require('../models/TranslationSuggestion');
const User = require('../models/User');
const Identification = require('../models/Identification');

// All admin routes require: first regular auth (user logged in), then admin check
// Apply both middlewares in order

// GET /api/admin/pending - Get all pending translation suggestions
router.get('/pending', auth, adminAuth, async (req, res) => {
  try {
    // Find all suggestions with status 'pending'
    // Populate('user') means: also fetch the user's details (name, email)
    const suggestions = await TranslationSuggestion.find({ status: 'pending' })
      .populate('user', 'name email')  // Get user's name and email
      .sort({ createdAt: -1 });        // Newest first
    
    res.json({
      success: true,
      suggestions: suggestions
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
    const suggestions = await TranslationSuggestion.find({ status: 'approved' })
      .populate('user', 'name email')
      .sort({ reviewedAt: -1 });
    
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
    
    // Find the suggestion
    const suggestion = await TranslationSuggestion.findById(suggestionId);
    
    if (!suggestion) {
      return res.status(404).json({ success: false, message: 'Suggestion not found' });
    }
    
    // Update suggestion status
    suggestion.status = 'approved';
    suggestion.reviewedAt = new Date();
    suggestion.reviewedBy = adminId;
    
    await suggestion.save();
    
    // TODO: Also add to PlantTranslations in your Flutter app
    // For now, just mark as approved
    
    res.json({
      success: true,
      message: 'Translation approved successfully'
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
    
    const suggestion = await TranslationSuggestion.findById(suggestionId);
    
    if (!suggestion) {
      return res.status(404).json({ success: false, message: 'Suggestion not found' });
    }
    
    suggestion.status = 'rejected';
    suggestion.reviewedAt = new Date();
    suggestion.reviewedBy = adminId;
    suggestion.rejectionReason = reason || null;
    
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
    // Get counts of suggestions by status
    const pendingCount = await TranslationSuggestion.countDocuments({ status: 'pending' });
    const approvedCount = await TranslationSuggestion.countDocuments({ status: 'approved' });
    const rejectedCount = await TranslationSuggestion.countDocuments({ status: 'rejected' });
    
    // Get total users
    const totalUsers = await User.countDocuments();
    
    // Get total identifications
    const totalIdentifications = await Identification.countDocuments();
    
    // Get recent activity (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentSuggestions = await TranslationSuggestion.countDocuments({
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