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
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Plant',
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
    required: function() {
      return this.type === 'translation_suggestion';
    }
  },
  suggestedTamazight: {
    type: String,
    required: function() {
      return this.type === 'translation_suggestion';
    }
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
  
  // Stats
  likes: {
    type: Number,
    default: 0
  },
  commentCount: {
    type: Number,
    default: 0
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

module.exports = mongoose.model('FeedPost', feedPostSchema);
