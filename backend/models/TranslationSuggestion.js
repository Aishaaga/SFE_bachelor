const mongoose = require('mongoose');

const TranslationSuggestionSchema = new mongoose.Schema({
  // Informations sur la plante
  scientificName: {
    type: String,
    required: true,
    trim: true
  },
  
  // Propositions de traduction
  darijaProposal: {
    type: String,
    trim: true,
    default: null
  },
  tamazightProposal: {
    type: String,
    trim: true,
    default: null
  },
  
  // Informations du contributeur
  contributorName: {
    type: String,
    required: true,
    trim: true
  },
  contributorEmail: {
    type: String,
    required: true,
    trim: true,
    lowercase: true
  },
  contributorRegion: {
    type: String,
    trim: true,
    default: ''
  },
  
  // Notes additionnelles
  notes: {
    type: String,
    trim: true,
    default: ''
  },
  
  // Statut de la proposition
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'needs_review'],
    default: 'pending'
  },
  
  // Métadonnées
  submittedAt: {
    type: Date,
    default: Date.now
  },
  reviewedAt: {
    type: Date,
    default: null
  },
  reviewedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  reviewNotes: {
    type: String,
    trim: true,
    default: ''
  },
  
  // Source de la proposition
  source: {
    type: String,
    enum: ['mobile_app', 'web_app', 'admin'],
    default: 'mobile_app'
  },
  
  // Validation
  isValidated: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true // Ajoute createdAt et updatedAt automatiquement
});

// Index pour la recherche rapide
TranslationSuggestionSchema.index({ scientificName: 1, status: 1 });
TranslationSuggestionSchema.index({ contributorEmail: 1 });
TranslationSuggestionSchema.index({ submittedAt: -1 });
TranslationSuggestionSchema.index({ status: 1, submittedAt: -1 });

// Validation : au moins une proposition doit exister
TranslationSuggestionSchema.pre('save', async function() {
  if (!this.darijaProposal && !this.tamazightProposal) {
    const error = new Error('Au moins une proposition (Darija ou Tamazight) est requise');
    throw error;
  }
});

// Méthode virtuelle pour vérifier si la proposition est valide
TranslationSuggestionSchema.virtual('hasValidProposal').get(function() {
  return (this.darijaProposal && this.darijaProposal.trim().length > 0) ||
         (this.tamazightProposal && this.tamazightProposal.trim().length > 0);
});

// Méthode pour approuver une proposition
TranslationSuggestionSchema.methods.approve = function(adminId, reviewNotes = '') {
  this.status = 'approved';
  this.reviewedAt = new Date();
  this.reviewedBy = adminId;
  this.reviewNotes = reviewNotes;
  this.isValidated = true;
  return this.save();
};

// Méthode pour rejeter une proposition
TranslationSuggestionSchema.methods.reject = function(adminId, reviewNotes = '') {
  this.status = 'rejected';
  this.reviewedAt = new Date();
  this.reviewedBy = adminId;
  this.reviewNotes = reviewNotes;
  this.isValidated = false;
  return this.save();
};

// Méthode pour marquer comme nécessitant une review
TranslationSuggestionSchema.methods.requestReview = function(adminId, reviewNotes = '') {
  this.status = 'needs_review';
  this.reviewedAt = new Date();
  this.reviewedBy = adminId;
  this.reviewNotes = reviewNotes;
  return this.save();
};

// Méthodes statiques pour les statistiques
TranslationSuggestionSchema.statics.getStats = function() {
  return this.aggregate([
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 }
      }
    }
  ]);
};

TranslationSuggestionSchema.statics.getStatsByDateRange = function(startDate, endDate) {
  return this.aggregate([
    {
      $match: {
        submittedAt: {
          $gte: startDate,
          $lte: endDate
        }
      }
    },
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 }
      }
    }
  ]);
};

// Transformer en JSON pour l'API
TranslationSuggestionSchema.methods.toJSON = function() {
  const proposal = this.toObject();
  delete proposal.__v;
  return proposal;
};

module.exports = mongoose.model('TranslationSuggestion', TranslationSuggestionSchema);
