const mongoose = require('mongoose');

const feedLikeSchema = new mongoose.Schema({
  // The feed post being liked
  feedPostId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'FeedPost',
    required: true
  },
  
  // The user who liked the post
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // Timestamp
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Compound index to ensure a user can only like a post once
feedLikeSchema.index({ feedPostId: 1, userId: 1 }, { unique: true });

// Additional indexes for queries
feedLikeSchema.index({ feedPostId: 1 });
feedLikeSchema.index({ userId: 1 });
feedLikeSchema.index({ createdAt: -1 });

// Method to check if a user has liked a post
feedLikeSchema.statics.isUserLiked = async function(feedPostId, userId) {
  const like = await this.findOne({ feedPostId, userId });
  return !!like;
};

// Method to get like count for a post
feedLikeSchema.statics.getLikeCount = async function(feedPostId) {
  return await this.countDocuments({ feedPostId });
};

// Method to toggle a like (add if doesn't exist, remove if exists)
feedLikeSchema.statics.toggleLike = async function(feedPostId, userId) {
  const existingLike = await this.findOne({ feedPostId, userId });
  
  if (existingLike) {
    await this.deleteOne({ _id: existingLike._id });
    return { liked: false, action: 'unliked' };
  } else {
    await this.create({ feedPostId, userId });
    return { liked: true, action: 'liked' };
  }
};

module.exports = mongoose.model('FeedLike', feedLikeSchema);
