const mongoose = require('mongoose');

const feedPostSchema = new mongoose.Schema({
  // What type of post?
  type: {
    type: String,
    enum: ['identification', 'translation_suggestion', 'plant_of_day'],
    required: true,
    default: 'identification'
  },
  
  // Who posted it?
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  isAnonymous: {
    type: Boolean,
    default: false
  },
  
  // What plant is this about?
  plantId: {
    type: mongoose.Schema.Types.Mixed, // Allow both ObjectId and string
    required: true
  },
  plantName: {
    type: String,
    required: true
  },
  scientificName: {
    type: String,
    required: true
  },
  
  // For identification posts
  imageUrl: {
    type: String,
    required: function() {
      return this.type === 'identification';
    }
  },
  identificationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Identification',
    required: function() {
      return this.type === 'identification';
    }
  },
  
  // For translation suggestion posts
  suggestedDarija: {
    type: String,
    required: false // Make optional for translation suggestions
  },
  suggestedTamazight: {
    type: String,
    required: false // Make optional for translation suggestions
  },
  upvotes: {
    type: Number,
    default: 0
  },
  downvotes: {
    type: Number,
    default: 0
  },
  
  // Location
  location: {
    level: {
      type: String,
      enum: ['country', 'city', 'none'],
      default: 'country'
    },
    country: {
      type: String,
      default: 'Morocco'
    },
    city: {
      type: String,
      required: function() {
        return this.location.level === 'city';
      }
    }
  },
  
  // Stats - likes only for identification posts
  likes: {
    type: Number,
    default: 0,
    required: function() {
      return this.type === 'identification';
    }
  },
  
  // Status
  status: {
    type: String,
    enum: ['active', 'flagged', 'hidden', 'deleted'],
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

// Index for queries
feedPostSchema.index({ type: 1, status: 1, createdAt: -1 });
feedPostSchema.index({ plantId: 1 });
feedPostSchema.index({ userId: 1 });
feedPostSchema.index({ 'location.level': 1, 'location.city': 1 });

// Virtual methods for getting counts from relationships
feedPostSchema.virtual('likeCount', {
  ref: 'FeedLike',
  localField: '_id',
  foreignField: 'feedPostId',
  count: true
});

feedPostSchema.virtual('commentCount', {
  ref: 'FeedComment', 
  localField: '_id',
  foreignField: 'feedPostId',
  count: true
});

// Method to get full post data with counts
feedPostSchema.methods.getWithCounts = async function() {
  const FeedLike = mongoose.model('FeedLike');
  const FeedComment = mongoose.model('FeedComment');
  
  const [likeCount, commentCount] = await Promise.all([
    FeedLike.getLikeCount(this._id),
    FeedComment.getCommentCount(this._id)
  ]);
  
  const postObj = this.toObject();
  postObj.likeCount = likeCount;
  postObj.commentCount = commentCount;
  
  return postObj;
};

// Method to check if user liked the post
feedPostSchema.methods.isUserLiked = async function(userId) {
  const FeedLike = mongoose.model('FeedLike');
  return await FeedLike.isUserLiked(this._id, userId);
};

module.exports = mongoose.model('FeedPost', feedPostSchema);
