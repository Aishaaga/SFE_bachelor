const mongoose = require('mongoose');

const contentReportSchema = new mongoose.Schema({
  contentType: {
    type: String,
    enum: ['identification', 'translation'],
    required: true
  },
  contentId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  reportedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  reason: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'reviewed', 'dismissed'],
    default: 'pending'
  },
  reviewedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  reviewedAt: {
    type: Date,
    default: null
  }
}, {
  timestamps: true
});

// Indexes for efficient queries
contentReportSchema.index({ contentType: 1, contentId: 1 });
contentReportSchema.index({ reportedBy: 1 });
contentReportSchema.index({ status: 1 });
contentReportSchema.index({ createdAt: -1 });

// Prevent duplicate reports from same user on same content
contentReportSchema.index({ contentType: 1, contentId: 1, reportedBy: 1 }, { unique: true });

module.exports = mongoose.model('ContentReport', contentReportSchema);
