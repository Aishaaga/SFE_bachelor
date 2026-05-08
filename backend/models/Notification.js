const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  // Who receives this notification?
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // Type of notification
  type: {
    type: String,
    enum: [
      'translation_approved',
      'translation_rejected',
      'translation_featured',
      'like_received',
      'comment_received'
    ],
    required: true
  },
  
  // Content of the notification
  title: {
    type: String,
    required: true
  },
  
  message: {
    type: String,
    required: true
  },
  
  // Related data (what this notification is about)
  relatedId: {
    type: mongoose.Schema.Types.ObjectId,
    refPath: 'relatedModel'
  },
  
  relatedModel: {
    type: String,
    enum: ['TranslationSuggestion', 'FeedPost', 'FeedComment']
  },
  
  // Additional data (store as JSON)
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  
  // Status
  isRead: {
    type: Boolean,
    default: false
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Index for faster queries
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, isRead: 1 });

module.exports = mongoose.model('Notification', notificationSchema);