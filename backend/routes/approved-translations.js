const express = require('express');
const authMiddleware = require('../middleware/auth');
const ApprovedTranslation = require('../models/ApprovedTranslation');
const User = require('../models/User');

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// GET /api/approved-translations - Get all approved translations
router.get('/', async (req, res) => {
  try {
    const {
      scientificName,
      contributorEmail,
      status = 'active',
      page = 1,
      limit = 20,
      sortBy = 'approvedAt',
      sortOrder = 'desc'
    } = req.query;
    
    // Build filter
    const filter = {};
    if (status) filter.status = status;
    if (scientificName) {
      filter.scientificName = { $regex: scientificName, $options: 'i' };
    }
    if (contributorEmail) {
      filter.contributorEmail = { $regex: contributorEmail, $options: 'i' };
    }
    
    // Build sort
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const translations = await ApprovedTranslation.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit))
      .populate('approvedBy', 'name email')
      .populate('suggestedBy', 'name email');
    
    const total = await ApprovedTranslation.countDocuments(filter);
    
    res.json({
      success: true,
      translations: translations,
      pagination: {
        current: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
    
  } catch (error) {
    console.error('Error fetching approved translations:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching approved translations'
    });
  }
});

// GET /api/approved-translations/:scientificName - Get translation for specific plant
router.get('/plant/:scientificName', async (req, res) => {
  try {
    const { scientificName } = req.params;
    
    const translation = await ApprovedTranslation.getForPlant(scientificName.trim());
    
    if (!translation) {
      return res.status(404).json({
        success: false,
        message: 'No approved translation found for this plant'
      });
    }
    
    res.json({
      success: true,
      translation: translation
    });
    
  } catch (error) {
    console.error('Error fetching plant translation:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching plant translation'
    });
  }
});

// GET /api/approved-translations/stats - Get statistics
router.get('/stats', async (req, res) => {
  try {
    const stats = await ApprovedTranslation.getStats();
    
    res.json({
      success: true,
      stats: stats
    });
    
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching statistics'
    });
  }
});

// PUT /api/approved-translations/:id/status - Update translation status (admin only)
router.put('/:id/status', async (req, res) => {
  try {
    const { status, notes } = req.body;
    const translationId = req.params.id;
    
    // Check if user is admin (you might need to add admin middleware)
    const user = await User.findById(req.userId);
    if (!user || user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Admin access required'
      });
    }
    
    if (!['active', 'deprecated', 'under_review'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }
    
    const translation = await ApprovedTranslation.findById(translationId);
    
    if (!translation) {
      return res.status(404).json({
        success: false,
        message: 'Translation not found'
      });
    }
    
    // Update status
    translation.status = status;
    translation.updatedAt = new Date();
    if (notes) {
      translation.notes = (translation.notes || '') + `\n\nStatus update: ${notes}`;
    }
    
    await translation.save();
    
    res.json({
      success: true,
      message: `Translation status updated to: ${status}`,
      translation: translation
    });
    
  } catch (error) {
    console.error('Error updating translation status:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating translation status'
    });
  }
});

// DELETE /api/approved-translations/:id - Delete approved translation (admin only)
router.delete('/:id', async (req, res) => {
  try {
    const translationId = req.params.id;
    
    // Check if user is admin
    const user = await User.findById(req.userId);
    if (!user || user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Admin access required'
      });
    }
    
    const result = await ApprovedTranslation.findByIdAndDelete(translationId);
    
    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Translation not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Approved translation deleted successfully'
    });
    
  } catch (error) {
    console.error('Error deleting approved translation:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting approved translation'
    });
  }
});

// GET /api/approved-translations/search - Search approved translations
router.get('/search', async (req, res) => {
  try {
    const {
      q, // search term
      status,
      contributorEmail,
      startDate,
      endDate,
      page = 1,
      limit = 10
    } = req.query;
    
    const filter = {};
    
    // Text search
    if (q) {
      filter.$or = [
        { scientificName: { $regex: q, $options: 'i' } },
        { plantName: { $regex: q, $options: 'i' } },
        { darijaTranslation: { $regex: q, $options: 'i' } },
        { tamazightTranslation: { $regex: q, $options: 'i' } },
        { contributorName: { $regex: q, $options: 'i' } }
      ];
    }
    
    if (status) filter.status = status;
    if (contributorEmail) filter.contributorEmail = { $regex: contributorEmail, $options: 'i' };
    
    // Date filtering
    if (startDate || endDate) {
      filter.approvedAt = {};
      if (startDate) filter.approvedAt.$gte = new Date(startDate);
      if (endDate) filter.approvedAt.$lte = new Date(endDate);
    }
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const translations = await ApprovedTranslation.find(filter)
      .sort({ approvedAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .populate('approvedBy', 'name email')
      .populate('suggestedBy', 'name email');
    
    const total = await ApprovedTranslation.countDocuments(filter);
    
    res.json({
      success: true,
      translations: translations,
      pagination: {
        current: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
    
  } catch (error) {
    console.error('Error searching approved translations:', error);
    res.status(500).json({
      success: false,
      message: 'Error searching approved translations'
    });
  }
});

module.exports = router;
