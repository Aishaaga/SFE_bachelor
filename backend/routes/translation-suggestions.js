const express = require('express');
const authMiddleware = require('../middleware/auth');
const TranslationSuggestion = require('../models/TranslationSuggestion');

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
    
    // Créer la proposition
    const proposal = new TranslationSuggestion({
      scientificName: scientificName.trim(),
      darijaProposal: darijaProposal ? darijaProposal.trim() : null,
      tamazightProposal: tamazightProposal ? tamazightProposal.trim() : null,
      contributorName: contributorName.trim(),
      contributorEmail: contributorEmail.toLowerCase().trim(),
      contributorRegion: contributorRegion ? contributorRegion.trim() : '',
      notes: notes ? notes.trim() : '',
      source: 'mobile_app'
    });
    
    await proposal.save();
    
    res.status(201).json({
      success: true,
      message: 'Proposition de traduction soumise avec succès',
      proposal: proposal.toJSON()
    });
    
  } catch (error) {
    console.error('Erreur création proposition:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création de la proposition'
    });
  }
});

// GET /api/translation-proposals - Lister toutes les propositions (admin)
router.get('/', authMiddleware, async (req, res) => {
  try {
    const {
      status,
      scientificName,
      contributorName,
      page = 1,
      limit = 20,
      sortBy = 'submittedAt',
      sortOrder = 'desc'
    } = req.query;
    
    // Construire le filtre
    const filter = {};
    if (status) filter.status = status;
    if (scientificName) {
      filter.scientificName = { $regex: scientificName, $options: 'i' };
    }
    if (contributorName) {
      filter.contributorName = { $regex: contributorName, $options: 'i' };
    }
    
    // Construire le tri
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const proposals = await TranslationSuggestion.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit))
      .populate('reviewedBy', 'name email');
    
    const total = await TranslationSuggestion.countDocuments(filter);
    
    res.json({
      success: true,
      proposals: proposals.map(p => p.toJSON()),
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
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    const stats = await TranslationSuggestion.getStats();
    
    // Formater les statistiques
    const formattedStats = {
      total: 0,
      pending: 0,
      approved: 0,
      rejected: 0,
      needs_review: 0
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
router.put('/:id/status', authMiddleware, async (req, res) => {
  try {
    const { status, reviewNotes } = req.body;
    const proposalId = req.params.id;
    
    if (!['pending', 'approved', 'rejected', 'needs_review'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Statut invalide'
      });
    }
    
    const proposal = await TranslationSuggestion.findById(proposalId);
    
    if (!proposal) {
      return res.status(404).json({
        success: false,
        message: 'Proposition non trouvée'
      });
    }
    
    // Mettre à jour le statut
    proposal.status = status;
    proposal.reviewedAt = new Date();
    proposal.reviewedBy = req.userId;
    proposal.reviewNotes = reviewNotes || '';
    proposal.isValidated = status === 'approved';
    
    await proposal.save();
    
    res.json({
      success: true,
      message: `Statut mis à jour: ${status}`,
      proposal: proposal.toJSON()
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
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const proposalId = req.params.id;
    
    const result = await TranslationSuggestion.findByIdAndDelete(proposalId);
    
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
    const { status = 'approved' } = req.query;
    
    const proposals = await TranslationSuggestion.find({
      scientificName: scientificName.trim(),
      status: status
    }).sort({ submittedAt: -1 });
    
    res.json({
      success: true,
      proposals: proposals.map(p => p.toJSON())
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
    
    const filter = {};
    
    // Recherche textuelle
    if (q) {
      filter.$or = [
        { scientificName: { $regex: q, $options: 'i' } },
        { darijaProposal: { $regex: q, $options: 'i' } },
        { tamazightProposal: { $regex: q, $options: 'i' } },
        { contributorName: { $regex: q, $options: 'i' } },
        { notes: { $regex: q, $options: 'i' } }
      ];
    }
    
    // Filtres spécifiques
    if (status) filter.status = status;
    if (contributorEmail) filter.contributorEmail = contributorEmail.toLowerCase();
    
    // Filtre de date
    if (startDate || endDate) {
      filter.submittedAt = {};
      if (startDate) filter.submittedAt.$gte = new Date(startDate);
      if (endDate) filter.submittedAt.$lte = new Date(endDate);
    }
    
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const proposals = await TranslationSuggestion.find(filter)
      .sort({ submittedAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .populate('reviewedBy', 'name email');
    
    const total = await TranslationSuggestion.countDocuments(filter);
    
    res.json({
      success: true,
      proposals: proposals.map(p => p.toJSON()),
      pagination: {
        current: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
    
  } catch (error) {
    console.error('Erreur recherche:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la recherche'
    });
  }
});

module.exports = router;
