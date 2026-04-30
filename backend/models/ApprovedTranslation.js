const mongoose = require('mongoose');

const approvedTranslationSchema = new mongoose.Schema({
  // Plant information
  scientificName: {
    type: String,
    required: true,
    trim: true
  },
  plantName: {
    type: String,
    required: true,
    trim: true
  },
  
  // Approved translations
  darijaTranslation: {
    type: String,
    required: false,
    trim: true
  },
  tamazightTranslation: {
    type: String,
    required: false,
    trim: true
  },
  
  // Who suggested this translation
  suggestedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false
  },
  contributorName: {
    type: String,
    required: false,
    trim: true,
    default: 'Anonymous'
  },
  contributorEmail: {
    type: String,
    required: false,
    trim: true,
    default: ''
  },
  contributorRegion: {
    type: String,
    required: false,
    trim: true
  },
  
  // Approval information
  approvedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  approvedAt: {
    type: Date,
    default: Date.now
  },
  
  // Original suggestion reference
  originalSuggestionId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'FeedPost',
    required: true
  },
  
  // Voting data at time of approval
  upvotesAtApproval: {
    type: Number,
    default: 0
  },
  downvotesAtApproval: {
    type: Number,
    default: 0
  },
  totalVotesAtApproval: {
    type: Number,
    default: 0
  },
  
  // Additional notes
  notes: {
    type: String,
    required: false,
    trim: true
  },
  
  // Status for approved translations
  status: {
    type: String,
    enum: ['active', 'deprecated', 'under_review'],
    default: 'active'
  },
  
  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Indexes for efficient queries
approvedTranslationSchema.index({ scientificName: 1 });
approvedTranslationSchema.index({ status: 1, approvedAt: -1 });
approvedTranslationSchema.index({ approvedBy: 1 });
approvedTranslationSchema.index({ suggestedBy: 1 });
approvedTranslationSchema.index({ contributorEmail: 1 });

// Method to check if translation exists for a plant
approvedTranslationSchema.statics.existsForPlant = async function(scientificName) {
  const count = await this.countDocuments({ 
    scientificName: scientificName.trim(),
    status: 'active'
  });
  return count > 0;
};

// Method to get approved translation for a plant
approvedTranslationSchema.statics.getForPlant = async function(scientificName) {
  return await this.findOne({ 
    scientificName: scientificName.trim(),
    status: 'active'
  }).populate('approvedBy', 'name email')
   .populate('suggestedBy', 'name email');
};

// Method to get all approved translations
approvedTranslationSchema.statics.getAllActive = async function() {
  return await this.find({ status: 'active' })
    .populate('approvedBy', 'name email')
    .populate('suggestedBy', 'name email')
    .sort({ approvedAt: -1 });
};

// Method to get statistics
approvedTranslationSchema.statics.getStats = async function() {
  const stats = await this.aggregate([
    {
      $group: {
        _id: '$status',
        count: { $sum: 1 }
      }
    }
  ]);
  
  const formattedStats = {
    total: 0,
    active: 0,
    deprecated: 0,
    under_review: 0
  };
  
  stats.forEach(stat => {
    formattedStats[stat._id] = stat.count;
    formattedStats.total += stat.count;
  });
  
  return formattedStats;
};

module.exports = mongoose.model('ApprovedTranslation', approvedTranslationSchema);
