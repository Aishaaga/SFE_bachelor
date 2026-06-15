const mongoose = require('mongoose');

const hiddenContentSchema = new mongoose.Schema({
  contentType: {
    type: String,
    enum: ['identification', 'translation'],
    required: true
  },
  contentId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  hiddenBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  hiddenAt: {
    type: Date,
    default: Date.now
  },
  reason: {
    type: String,
    default: ''
  }
}, {
  timestamps: true
});

// Indexes for efficient queries
hiddenContentSchema.index({ contentType: 1, contentId: 1 });
hiddenContentSchema.index({ hiddenBy: 1 });
hiddenContentSchema.index({ hiddenAt: -1 });

module.exports = mongoose.model('HiddenContent', hiddenContentSchema);
