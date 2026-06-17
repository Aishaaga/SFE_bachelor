// Purpose: All admin API endpoints
// Location: sfe-backend/routes/admin.js

const express = require('express');
const router = express.Router();
const adminAuth = require('../middleware/adminAuth');
const auth = require('../middleware/auth'); // Regular auth first
const TranslationSuggestion = require('../models/TranslationSuggestion');
const FeedPost = require('../models/FeedPost');
const FeedComment = require('../models/FeedComment');
const HiddenContent = require('../models/HiddenContent');
const ContentReport = require('../models/ContentReport');
const TranslationVote = require('../models/TranslationVote');
const User = require('../models/User');
const Identification = require('../models/Identification');
const ApprovedTranslation = require('../models/ApprovedTranslation');
const NotificationService = require('../services/notificationService');

// All admin routes require: first regular auth (user logged in), then admin check
// Apply both middlewares in order

// GET /api/admin/pending - Get all active translation suggestions with vote counts
router.get('/pending', auth, adminAuth, async (req, res) => {
  try {
    // Find all translation suggestions with status 'active'
    const suggestions = await FeedPost.find({ 
      type: 'translation_suggestion',
      status: 'active'
    })
      .populate('userId', 'name email')
      .populate('identificationId')
      .sort({ createdAt: -1 });
    
    // Get vote counts for all suggestions
    const suggestionIds = suggestions.map(s => s._id.toString());
    const voteMap = await TranslationVote.getBatchVoteCounts(suggestionIds);
    
    // Transform data for dashboard compatibility
    const transformedSuggestions = await Promise.all(suggestions.map(async s => {
      let userName = 'Inconnu';
      let userEmail = '';

      // Try to get user from userId first
      if (s.userId) {
        userName = s.userId.name;
        userEmail = s.userId.email;
      }
      // If userId is null but we have identificationId, fetch from identification
      else if (s.identificationId) {
        try {
          const identificationId = s.identificationId._id || s.identificationId;
          const identification = await Identification.findById(identificationId).populate('user', 'name email username');
          if (identification && identification.user) {
            userName = identification.user.name;
            userEmail = identification.user.email;
          }
        } catch (err) {
          console.log('Could not fetch user from identification:', err.message);
        }
      }

      return {
        _id: s._id,
        plantScientificName: s.scientificName,
        suggestedDarija: s.suggestedDarija,
        suggestedTamazight: s.suggestedTamazight,
        user: {
          name: userName,
          email: userEmail
        },
        isAnonymous: s.isAnonymous, // Include isAnonymous flag for reference
        status: 'pending', // Map 'flagged' to 'pending' for dashboard
        submittedAt: s.createdAt,
        contributorName: userName,
        contributorEmail: userEmail,
        contributorRegion: s.location?.city || '',
        notes: s.notes || '',
        // Include vote counts
        upvotes: voteMap[s._id.toString()]?.upvotes || 0,
        downvotes: voteMap[s._id.toString()]?.downvotes || 0,
        totalVotes: voteMap[s._id.toString()]?.total || 0
      };
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

// GET /api/admin/test - Test endpoint
router.get('/test', auth, adminAuth, async (req, res) => {
  console.log('🔥 ADMIN TEST ENDPOINT CALLED');
  res.json({ success: true, message: 'Admin routes are working!' });
});

// POST /api/admin/approve/:id - Approve a suggestion
router.post('/approve/:id', auth, adminAuth, async (req, res) => {
  try {
    
    console.log('🔥 APPROVAL REQUEST RECEIVED');
    console.log('- Suggestion ID:', req.params.id);
    console.log('- Admin ID:', req.userId);
    console.log('- Request body:', req.body);
    
    const suggestionId = req.params.id;
    const adminId = req.userId;
    
    // Find the suggestion in FeedPost
    console.log('🔍 Finding suggestion...');
    const suggestion = await FeedPost.findById(suggestionId);
    console.log('🔍 Found suggestion:', suggestion ? 'YES' : 'NO');
    
    if (!suggestion) {
      console.log('❌ Suggestion not found');
      return res.status(404).json({ success: false, message: 'Suggestion not found' });
    }
    
    // Get vote counts for this suggestion
    console.log('🔍 Getting vote counts...');
    const voteMap = await TranslationVote.getBatchVoteCounts([suggestionId]);
    const votes = voteMap[suggestionId] || { upvotes: 0, downvotes: 0, total: 0 };
    console.log('🔍 Vote counts:', votes);
    
    // Check if translation already exists for this plant
    console.log('🔍 Checking existing translations...');
    const existingTranslations = await ApprovedTranslation.getAllForPlant(suggestion.scientificName);
    console.log('🔍 Existing translations:', existingTranslations.length, 'found');
    
    // Allow multiple translations - don't replace existing ones
    if (existingTranslations.length > 0) {
      console.log('ℹ️ Adding new translation to existing', existingTranslations.length, 'translations');
    }
    
    // Get user info for contributor
    console.log('🔍 Getting contributor info...');
    let contributorName = 'Anonymous';
    let contributorEmail = '';
    if (suggestion.userId) {
      try {
        const user = await User.findById(suggestion.userId);
        if (user) {
          contributorName = user.name;
          contributorEmail = user.email;
        }
      } catch (err) {
        console.log('Could not fetch user info:', err.message);
      }
    }
    console.log('🔍 Contributor:', contributorName, contributorEmail);
    
    // Create approved translation record
    console.log('🔍 Creating ApprovedTranslation...');
    const approvedTranslation = new ApprovedTranslation({
      scientificName: suggestion.scientificName,
      plantName: suggestion.plantName,
      darijaTranslation: suggestion.suggestedDarija,
      tamazightTranslation: suggestion.suggestedTamazight,
      suggestedBy: suggestion.userId,
      contributorName: contributorName,
      contributorEmail: contributorEmail,
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
    
    console.log('🔍 Saving ApprovedTranslation...');
    await approvedTranslation.save();
    await NotificationService.translationApproved(suggestion.userId, suggestion);
    console.log('✅ ApprovedTranslation saved:', approvedTranslation._id);
    
    // Update suggestion status to indicate it's been approved
    console.log('🔍 Updating suggestion status...');
    suggestion.status = 'approved';
    suggestion.updatedAt = new Date();
    await suggestion.save();
    console.log('✅ FeedPost status updated to approved:', suggestion._id);
    
    // Note: We NO LONGER hide competing suggestions - allow multiple suggestions to coexist
    // This allows admin to approve multiple translations for the same plant
    console.log('ℹ️ Other suggestions for this plant remain active for potential approval');
    
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
    
    suggestion.status = 'refused'; // rejected = refused (not hidden, stays in feed)
    suggestion.updatedAt = new Date();
    // Store rejection reason in notes field for now
    if (reason) {
      suggestion.notes = (suggestion.notes || '') + `\n\nRejection reason: ${reason}`;
    }
    
    await suggestion.save();
    await NotificationService.translationRejected(suggestion.userId, suggestion, reason);
    

    
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
    
    // Get unique plants with approved translations
    const approvedPlants = await ApprovedTranslation.find({ status: 'active' })
      .distinct('scientificName');
    const rejectedCount = await FeedPost.countDocuments({
      type: 'translation_suggestion',
      status: 'refused'
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
        users: totalUsers,
        identifications: totalIdentifications,
        suggestions: pendingCount + approvedCount + rejectedCount,
        recentSuggestions: recentSuggestions
      }
    });
    
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ success: false, message: 'Error fetching stats' });
  }
});

// GET /api/admin/users - Get all users with pagination and filtering
router.get('/users', auth, adminAuth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    const role = req.query.role || '';
    
    const skip = (page - 1) * limit;
    
    const query = {};
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    if (role) {
      query.role = role;
    }
    
    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);
    
    const total = await User.countDocuments(query);
    
    res.json({
      success: true,
      users: users,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ success: false, message: 'Error fetching users' });
  }
});

// GET /api/admin/users/:id - Get a specific user
router.get('/users/:id', auth, adminAuth, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    res.json({
      success: true,
      user: user
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ success: false, message: 'Error fetching user' });
  }
});

// PUT /api/admin/users/:id - Update user
router.put('/users/:id', auth, adminAuth, async (req, res) => {
  try {
    const { name, role, bio, location } = req.body;
    
    const user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    if (name !== undefined) user.name = name;
    if (role !== undefined) user.role = role;
    if (bio !== undefined) user.bio = bio;
    if (location !== undefined) user.location = location;
    
    await user.save();
    
    res.json({
      success: true,
      message: 'User updated successfully',
      user: user
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ success: false, message: 'Error updating user' });
  }
});

// DELETE /api/admin/users/:id - Delete a user
router.delete('/users/:id', auth, adminAuth, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user._id.toString() === req.userId) {
      return res.status(400).json({ success: false, message: 'Cannot delete yourself' });
    }

    await User.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ success: false, message: 'Error deleting user' });
  }
});

// POST /api/admin/users/:id/ban - Ban a user
router.post('/users/:id/ban', auth, adminAuth, async (req, res) => {
  try {
    const { reason } = req.body;
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user._id.toString() === req.userId) {
      return res.status(400).json({ success: false, message: 'Cannot ban yourself' });
    }

    user.isBanned = true;
    user.bannedAt = new Date();
    user.banReason = reason || '';
    await user.save();

    res.json({
      success: true,
      message: 'User banned successfully'
    });
  } catch (error) {
    console.error('Error banning user:', error);
    res.status(500).json({ success: false, message: 'Error banning user' });
  }
});

// POST /api/admin/users/:id/unban - Unban a user
router.post('/users/:id/unban', auth, adminAuth, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.isBanned = false;
    user.bannedAt = null;
    user.banReason = '';
    await user.save();

    res.json({
      success: true,
      message: 'User unbanned successfully'
    });
  } catch (error) {
    console.error('Error unbanning user:', error);
    res.status(500).json({ success: false, message: 'Error unbanning user' });
  }
});

// POST /api/admin/users/:id/disable - Disable a user
router.post('/users/:id/disable', auth, adminAuth, async (req, res) => {
  try {
    const { reason } = req.body;
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (user._id.toString() === req.userId) {
      return res.status(400).json({ success: false, message: 'Cannot disable yourself' });
    }

    user.isDisabled = true;
    user.disabledAt = new Date();
    user.disableReason = reason || '';
    await user.save();

    res.json({
      success: true,
      message: 'User disabled successfully'
    });
  } catch (error) {
    console.error('Error disabling user:', error);
    res.status(500).json({ success: false, message: 'Error disabling user' });
  }
});

// POST /api/admin/users/:id/enable - Enable a user
router.post('/users/:id/enable', auth, adminAuth, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.isDisabled = false;
    user.disabledAt = null;
    user.disableReason = '';
    await user.save();

    res.json({
      success: true,
      message: 'User enabled successfully'
    });
  } catch (error) {
    console.error('Error enabling user:', error);
    res.status(500).json({ success: false, message: 'Error enabling user' });
  }
});

// POST /api/admin/users/:id/reset-password - Reset user password
router.post('/users/:id/reset-password', auth, adminAuth, async (req, res) => {
  try {
    const { newPassword } = req.body;
    
    if (!newPassword || newPassword.length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
    }
    
    const user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    user.password = newPassword;
    await user.save();
    
    res.json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error) {
    console.error('Error resetting password:', error);
    res.status(500).json({ success: false, message: 'Error resetting password' });
  }
});


// ==================== SIMPLIFIED CONTENT MODERATION ENDPOINTS ====================

// GET /api/admin/moderation/identifications - Get all identification posts with filters
router.get('/moderation/identifications', auth, adminAuth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const reportedOnly = req.query.reportedOnly === 'true';
    const userId = req.query.userId;
    const dateRange = req.query.dateRange; // '7days', '30days', 'all'

    let query = { type: 'identification' };

    // Filter by reported content
    if (reportedOnly) {
      const reportedContentIds = await ContentReport.find({
        contentType: 'identification',
        status: 'pending'
      }).distinct('contentId');
      query._id = { $in: reportedContentIds };
    }

    // Filter by user
    if (userId) {
      query.userId = userId;
    }

    // Filter by date range
    if (dateRange === '7days') {
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      query.createdAt = { $gte: sevenDaysAgo };
    } else if (dateRange === '30days') {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      query.createdAt = { $gte: thirtyDaysAgo };
    }

    const posts = await FeedPost.find(query)
      .populate('userId', 'name email username')
      .populate('identificationId')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    // Get hidden content IDs and report counts for each post
    const postIds = posts.map(p => p._id);
    const hiddenContent = await HiddenContent.find({
      contentType: 'identification',
      contentId: { $in: postIds }
    });
    const hiddenContentIds = new Set(hiddenContent.map(h => h.contentId.toString()));

    const reports = await ContentReport.aggregate([
      { $match: { contentType: 'identification', contentId: { $in: postIds } } },
      { $group: { _id: '$contentId', count: { $sum: 1 } } }
    ]);
    const reportCounts = {};
    reports.forEach(r => { reportCounts[r._id.toString()] = r.count; });

    // Add status and report count to each post
    const postsWithStatus = await Promise.all(posts.map(async post => {
      const postObj = {
        ...post.toObject(),
        status: hiddenContentIds.has(post._id.toString()) ? 'hidden' : 'visible',
        reportCount: reportCounts[post._id.toString()] || 0
      };

      // If userId is null but we have an identificationId, fetch user from identification
      if (!postObj.userId && postObj.identificationId) {
        try {
          const identificationId = postObj.identificationId._id || postObj.identificationId;
          const identification = await Identification.findById(identificationId).populate('user', 'name email username');
          if (identification && identification.user) {
            postObj.userId = identification.user;
          }
        } catch (err) {
          console.log('Could not fetch user from identification:', err.message);
        }
      }

      return postObj;
    }));

    const total = await FeedPost.countDocuments(query);

    res.json({
      success: true,
      posts: postsWithStatus,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching identifications:', error);
    res.status(500).json({ success: false, message: 'Error fetching identifications' });
  }
});

// GET /api/admin/moderation/translations - Get all translation suggestions with filters
router.get('/moderation/translations', auth, adminAuth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const reportedOnly = req.query.reportedOnly === 'true';
    const userId = req.query.userId;
    const dateRange = req.query.dateRange; // '7days', '30days', 'all'

    let query = { type: 'translation_suggestion' };

    // Filter by reported content
    if (reportedOnly) {
      const reportedContentIds = await ContentReport.find({
        contentType: 'translation',
        status: 'pending'
      }).distinct('contentId');
      query._id = { $in: reportedContentIds };
    }

    // Filter by user
    if (userId) {
      query.userId = userId;
    }

    // Filter by date range
    if (dateRange === '7days') {
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      query.createdAt = { $gte: sevenDaysAgo };
    } else if (dateRange === '30days') {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      query.createdAt = { $gte: thirtyDaysAgo };
    }

    const posts = await FeedPost.find(query)
      .populate('userId', 'name email username')
      .populate('identificationId')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    // Get hidden content IDs and report counts for each post
    const postIds = posts.map(p => p._id);
    const hiddenContent = await HiddenContent.find({
      contentType: 'translation',
      contentId: { $in: postIds }
    });
    const hiddenContentIds = new Set(hiddenContent.map(h => h.contentId.toString()));

    const reports = await ContentReport.aggregate([
      { $match: { contentType: 'translation', contentId: { $in: postIds } } },
      { $group: { _id: '$contentId', count: { $sum: 1 } } }
    ]);
    const reportCounts = {};
    reports.forEach(r => { reportCounts[r._id.toString()] = r.count; });

    // Add status and report count to each post
    const postsWithStatus = await Promise.all(posts.map(async post => {
      const postObj = {
        ...post.toObject(),
        status: hiddenContentIds.has(post._id.toString()) ? 'hidden' : 'visible',
        reportCount: reportCounts[post._id.toString()] || 0
      };

      // If userId is null but we have an identificationId, fetch user from identification
      if (!postObj.userId && postObj.identificationId) {
        try {
          const identificationId = postObj.identificationId._id || postObj.identificationId;
          const identification = await Identification.findById(identificationId).populate('user', 'name email username');
          if (identification && identification.user) {
            postObj.userId = identification.user;
          }
        } catch (err) {
          console.log('Could not fetch user from identification:', err.message);
        }
      }

      return postObj;
    }));

    const total = await FeedPost.countDocuments(query);

    res.json({
      success: true,
      posts: postsWithStatus,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching translations:', error);
    res.status(500).json({ success: false, message: 'Error fetching translations' });
  }
});

// POST /api/admin/moderation/hide - Hide content
router.post('/moderation/hide', auth, adminAuth, async (req, res) => {
  try {
    const { contentType, contentId, reason } = req.body;

    // Check if already hidden
    const existingHidden = await HiddenContent.findOne({
      contentType,
      contentId
    });

    if (existingHidden) {
      return res.status(400).json({ success: false, message: 'Content already hidden' });
    }

    // Create hidden content record
    const hiddenContent = new HiddenContent({
      contentType,
      contentId,
      hiddenBy: req.userId,
      reason: reason || ''
    });

    await hiddenContent.save();

    res.json({
      success: true,
      message: 'Content hidden successfully'
    });
  } catch (error) {
    console.error('Error hiding content:', error);
    res.status(500).json({ success: false, message: 'Error hiding content' });
  }
});

// POST /api/admin/moderation/restore - Restore hidden content
router.post('/moderation/restore', auth, adminAuth, async (req, res) => {
  try {
    const { contentType, contentId } = req.body;

    await HiddenContent.deleteOne({
      contentType,
      contentId
    });

    res.json({
      success: true,
      message: 'Content restored successfully'
    });
  } catch (error) {
    console.error('Error restoring content:', error);
    res.status(500).json({ success: false, message: 'Error restoring content' });
  }
});

// DELETE /api/admin/moderation/delete - Permanently delete content
router.delete('/moderation/delete', auth, adminAuth, async (req, res) => {
  try {
    const { contentType, contentId } = req.body;

    // Delete from FeedPost
    await FeedPost.findByIdAndDelete(contentId);

    // Also remove from hidden content if exists
    await HiddenContent.deleteOne({
      contentType,
      contentId
    });

    // Mark all related reports as reviewed
    await ContentReport.updateMany(
      { contentType, contentId },
      { status: 'reviewed', reviewedBy: req.userId, reviewedAt: new Date() }
    );

    res.json({
      success: true,
      message: 'Content deleted permanently'
    });
  } catch (error) {
    console.error('Error deleting content:', error);
    res.status(500).json({ success: false, message: 'Error deleting content' });
  }
});

// GET /api/admin/moderation/reports/:contentType/:contentId - Get reports for specific content
router.get('/moderation/reports/:contentType/:contentId', auth, adminAuth, async (req, res) => {
  try {
    const { contentType, contentId } = req.params;

    const reports = await ContentReport.find({
      contentType,
      contentId
    })
      .populate('reportedBy', 'name email username')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      reports: reports
    });
  } catch (error) {
    console.error('Error fetching reports:', error);
    res.status(500).json({ success: false, message: 'Error fetching reports' });
  }
});


module.exports = router;


