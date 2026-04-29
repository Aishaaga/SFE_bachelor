const express = require('express');
const authMiddleware = require('../middleware/auth');
const FeedPost = require('../models/FeedPost');
const User = require('../models/User');

const router = express.Router();

// Toutes les routes suivantes nécessitent une authentification
router.use(authMiddleware);

// Route pour créer une proposition (authentification requise)
router.post('/', async (req, res) => {
  try {
    const {
      scientificName,
      darijaProposal,
      tamazightProposal,
      contributorName,
      contributorEmail,
      contributorRegion,
      notes
    } = req.body;
    
    // Validation
    if (!scientificName || !contributorName || !contributorEmail) {
      return res.status(400).json({
        success: false,
        message: 'Champs obligatoires manquants: scientificName, contributorName, contributorEmail'
      });
    }
    
    if (!darijaProposal && !tamazightProposal) {
      return res.status(400).json({
        success: false,
        message: 'Au moins une proposition (Darija ou Tamazight) est requise'
      });
    }
    
    // Vérifier le format de l'email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(contributorEmail)) {
      return res.status(400).json({
        success: false,
        message: 'Format d\'email invalide'
      });
    }
    
    // Find user by email
    const user = await User.findOne({ email: contributorEmail });
    
    // Create feed post for translation suggestion
    const feedPost = new FeedPost({
      type: 'translation_suggestion',
      userId: user ? user._id : null,
      isAnonymous: false,
      
      // Plant information
      plantId: `translation_${Date.now()}`,
      plantName: scientificName.trim(),
      scientificName: scientificName.trim(),
      
      // Translation suggestion fields
      suggestedDarija: darijaProposal ? darijaProposal.trim() : null,
      suggestedTamazight: tamazightProposal ? tamazightProposal.trim() : null,
      upvotes: 0,
      downvotes: 0,
      
      // Location
      location: {
        level: contributorRegion ? 'city' : 'country',
        country: 'Morocco',
        city: contributorRegion || undefined
      },
      
      // Status
      status: 'flagged', // New translation suggestions start as flagged for review
      
      // Metadata
      likes: 0,
      commentCount: 0,
      
      // Additional info
      notes: notes ? notes.trim() : ''
    });
    
    await feedPost.save();
    
    res.status(201).json({
      success: true,
      message: 'Proposition de traduction soumise avec succès',
      data: feedPost
    });
    
  } catch (error) {
    console.error('Erreur lors de la soumission de la proposition:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la soumission de la proposition'
    });
  }
});

// GET /api/translation-proposals - Lister toutes les propositions (admin)
router.get('/', async (req, res) => {
  try {
    const {
      status,
      scientificName,
      contributorName,
      page = 1,
      limit = 20,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;
    
    // Construire le filtre
    const filter = { type: 'translation_suggestion' };
    if (status) {
      // Map old status to new status
      const statusMap = {
        'pending': 'flagged',
        'approved': 'active',
        'rejected': 'hidden'
      };
      filter.status = statusMap[status] || status;
    }
    if (scientificName) {
      filter.scientificName = { $regex: scientificName, $options: 'i' };
    }
    
    // Construire le tri
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const proposals = await FeedPost.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit))
      .populate('userId', 'name email');
    
    const total = await FeedPost.countDocuments(filter);
    
    res.json({
      success: true,
      proposals: proposals,
      pagination: {
        current: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
    
  } catch (error) {
    console.error('Erreur listing propositions:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des propositions'
    });
  }
});

// GET /api/translation-proposals/stats - Statistiques (admin)
router.get('/stats', async (req, res) => {
  try {
    // Get statistics for translation suggestions
    const stats = await FeedPost.aggregate([
      { $match: { type: 'translation_suggestion' } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);
    
    // Formater les statistiques
    const formattedStats = {
      total: 0,
      flagged: 0,
      active: 0,
      hidden: 0
    };
    
    stats.forEach(stat => {
      formattedStats[stat._id] = stat.count;
      formattedStats.total += stat.count;
    });
    
    res.json({
      success: true,
      stats: formattedStats
    });
    
  } catch (error) {
    console.error('Erreur statistiques:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques'
    });
  }
});

// PUT /api/translation-proposals/:id/status - Mettre à jour le statut (admin)
router.put('/:id/status', async (req, res) => {
  try {
    const { status, reviewNotes } = req.body;
    const proposalId = req.params.id;
    
    if (!['flagged', 'active', 'hidden'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Statut invalide'
      });
    }
    
    const proposal = await FeedPost.findById(proposalId);
    
    if (!proposal) {
      return res.status(404).json({
        success: false,
        message: 'Proposition non trouvée'
      });
    }
    
    // Mettre à jour le statut
    proposal.status = status;
    proposal.updatedAt = new Date();
    
    await proposal.save();
    
    res.json({
      success: true,
      message: `Statut mis à jour: ${status}`,
      proposal: proposal
    });
    
  } catch (error) {
    console.error('Erreur mise à jour statut:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour du statut'
    });
  }
});

// DELETE /api/translation-proposals/:id - Supprimer une proposition (admin)
router.delete('/:id', async (req, res) => {
  try {
    const proposalId = req.params.id;
    
    const result = await FeedPost.findByIdAndDelete(proposalId);
    
    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Proposition non trouvée'
      });
    }
    
    res.json({
      success: true,
      message: 'Proposition supprimée avec succès'
    });
    
  } catch (error) {
    console.error('Erreur suppression proposition:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression'
    });
  }
});

// GET /api/translation-proposals/scientific/:scientificName - Proposer une plante spécifique
router.get('/scientific/:scientificName', async (req, res) => {
  try {
    const { scientificName } = req.params;
    const { status = 'active' } = req.query;
    
    const proposals = await FeedPost.find({
      type: 'translation_suggestion',
      scientificName: scientificName.trim(),
      status: status
    }).sort({ createdAt: -1 });
    
    res.json({
      success: true,
      proposals: proposals
    });
    
  } catch (error) {
    console.error('Erreur recherche par nom scientifique:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la recherche'
    });
  }
});

// GET /api/translation-proposals/search - Recherche avancée
router.get('/search', async (req, res) => {
  try {
    const {
      q, // terme de recherche
      status,
      contributorEmail,
      startDate,
      endDate,
      page = 1,
      limit = 10
    } = req.query;
    
    const filter = { type: 'translation_suggestion' };
    
    // Recherche textuelle
    if (q) {
      filter.$or = [
        { scientificName: { $regex: q, $options: 'i' } },
        { suggestedDarija: { $regex: q, $options: 'i' } },
        { suggestedTamazight: { $regex: q, $options: 'i' } }
      ];
    }
    
    if (status) filter.status = status;
    
    // Filtrage par date
    if (startDate || endDate) {
      filter.createdAt = {};
      if (startDate) filter.createdAt.$gte = new Date(startDate);
      if (endDate) filter.createdAt.$lte = new Date(endDate);
    }
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const proposals = await FeedPost.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .populate('userId', 'name email');
    
    const total = await FeedPost.countDocuments(filter);
    
    res.json({
      success: true,
      proposals: proposals,
      pagination: {
        current: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
    
  } catch (error) {
    console.error('Erreur recherche avancée:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la recherche'
    });
  }
});

module.exports = router;
