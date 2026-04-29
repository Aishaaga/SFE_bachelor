const mongoose = require('mongoose');

const translationVoteSchema = new mongoose.Schema({
  // The translation suggestion being voted on
  translationSuggestionId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'TranslationSuggestion',
    required: true
  },
  
  // The user who voted
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // Vote type: upvote or downvote
  voteType: {
    type: String,
    enum: ['upvote', 'downvote'],
    required: true
  },
  
  // Optional reason for the vote (especially for downvotes)
  reason: {
    type: String,
    trim: true,
    maxlength: 500
  },
  
  // Timestamp
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  // If vote was changed
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Compound index to ensure a user can only vote once per translation suggestion
translationVoteSchema.index({ translationSuggestionId: 1, userId: 1 }, { unique: true });

// Additional indexes for queries
translationVoteSchema.index({ translationSuggestionId: 1, voteType: 1 });
translationVoteSchema.index({ userId: 1 });
translationVoteSchema.index({ voteType: 1 });
translationVoteSchema.index({ createdAt: -1 });

// Method to get vote counts for a translation suggestion
translationVoteSchema.statics.getVoteCounts = async function(translationSuggestionId) {
  const result = await this.aggregate([
    { $match: { translationSuggestionId: mongoose.Types.ObjectId(translationSuggestionId) } },
    {
      $group: {
        _id: '$voteType',
        count: { $sum: 1 }
      }
    }
  ]);
  
  const counts = {
    upvotes: 0,
    downvotes: 0,
    total: 0
  };
  
  result.forEach(item => {
    if (item._id === 'upvote') {
      counts.upvotes = item.count;
    } else if (item._id === 'downvote') {
      counts.downvotes = item.count;
    }
  });
  
  counts.total = counts.upvotes + counts.downvotes;
  return counts;
};

// Method to get a user's vote on a translation suggestion
translationVoteSchema.statics.getUserVote = async function(translationSuggestionId, userId) {
  return await this.findOne({ translationSuggestionId, userId });
};

// Method to add or update a vote
translationVoteSchema.statics.castVote = async function(translationSuggestionId, userId, voteType, reason = null) {
  const existingVote = await this.findOne({ translationSuggestionId, userId });
  
  if (existingVote) {
    // Update existing vote
    const previousVoteType = existingVote.voteType;
    existingVote.voteType = voteType;
    existingVote.reason = reason;
    existingVote.updatedAt = new Date();
    await existingVote.save();
    
    return {
      vote: existingVote,
      action: 'updated',
      previousVoteType
    };
  } else {
    // Create new vote
    const newVote = await this.create({
      translationSuggestionId,
      userId,
      voteType,
      reason
    });
    
    return {
      vote: newVote,
      action: 'created',
      previousVoteType: null
    };
  }
};

// Method to remove a vote
translationVoteSchema.statics.removeVote = async function(translationSuggestionId, userId) {
  const vote = await this.findOne({ translationSuggestionId, userId });
  
  if (vote) {
    const previousVoteType = vote.voteType;
    await this.deleteOne({ _id: vote._id });
    
    return {
      action: 'removed',
      previousVoteType
    };
  }
  
  return {
    action: 'none',
    previousVoteType: null
  };
};

// Method to get vote statistics for multiple translation suggestions
translationVoteSchema.statics.getBatchVoteCounts = async function(translationSuggestionIds) {
  const objectIds = translationSuggestionIds.map(id => mongoose.Types.ObjectId(id));
  
  const results = await this.aggregate([
    { $match: { translationSuggestionId: { $in: objectIds } } },
    {
      $group: {
        _id: '$translationSuggestionId',
        upvotes: {
          $sum: { $cond: [{ $eq: ['$voteType', 'upvote'] }, 1, 0] }
        },
        downvotes: {
          $sum: { $cond: [{ $eq: ['$voteType', 'downvote'] }, 1, 0] }
        },
        total: { $sum: 1 }
      }
    }
  ]);
  
  // Convert to object format for easy lookup
  const voteMap = {};
  results.forEach(result => {
    voteMap[result._id.toString()] = {
      upvotes: result.upvotes,
      downvotes: result.downvotes,
      total: result.total
    };
  });
  
  return voteMap;
};

module.exports = mongoose.model('TranslationVote', translationVoteSchema);
