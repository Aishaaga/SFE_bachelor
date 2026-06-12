const mongoose = require('mongoose');

const feedCommentSchema = new mongoose.Schema({
  // The feed post being commented on
  feedPostId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'FeedPost',
    required: true
  },

  // The user who wrote the comment
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },

  // Comment content
  content: {
    type: String,
    required: true,
    trim: true,
    maxlength: 1000 // Reasonable limit for comments
  },

  // Anonymous comment flag
  isAnonymous: {
    type: Boolean,
    default: false
  },

  // Anonymous ID (random number to differentiate anonymous users)
  anonymousId: {
    type: Number,
    default: null
  },

  // For threaded comments (replies)
  parentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'FeedComment',
    default: null
  },

  // Comment status
  status: {
    type: String,
    enum: ['active', 'flagged', 'hidden', 'deleted'],
    default: 'active'
  },

  // Edit tracking
  isEdited: {
    type: Boolean,
    default: false
  },
  editedAt: {
    type: Date,
    default: null
  },

  // Timestamp
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
feedCommentSchema.index({ feedPostId: 1, status: 1, createdAt: 1 });
feedCommentSchema.index({ userId: 1 });
feedCommentSchema.index({ parentId: 1 });
feedCommentSchema.index({ status: 1, createdAt: -1 });

// Method to get comments for a feed post with pagination
feedCommentSchema.statics.getPostComments = async function(feedPostId, options = {}) {
  const {
    page = 1,
    limit = 20,
    status = 'active',
    sortBy = 'createdAt',
    sortOrder = 'asc'
  } = options;

  const skip = (page - 1) * limit;
  const sort = {};
  sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

  const comments = await this.find({ feedPostId, status })
    .populate('userId', 'username profileImage')
    .populate('parentId', 'content userId')
    .sort(sort)
    .skip(skip)
    .limit(limit);

  // Remove user data for anonymous comments but keep isAnonymous and anonymousId
  return comments.map(comment => {
    const commentObj = comment.toObject();
    if (commentObj.isAnonymous) {
      commentObj.userId = undefined;
    }
    return commentObj;
  });
};

// Method to get comment count for a post
feedCommentSchema.statics.getCommentCount = async function(feedPostId, status = 'active') {
  return await this.countDocuments({ feedPostId, status });
};

// Method to get replies for a comment
feedCommentSchema.statics.getReplies = async function(parentId, status = 'active') {
  const replies = await this.find({ parentId, status })
    .populate('userId', 'username profileImage')
    .sort({ createdAt: 1 });

  // Remove user data for anonymous comments but keep isAnonymous and anonymousId
  return replies.map(reply => {
    const replyObj = reply.toObject();
    if (replyObj.isAnonymous) {
      replyObj.userId = undefined;
    }
    return replyObj;
  });
};

// Method to edit a comment
feedCommentSchema.methods.editContent = function(newContent) {
  this.content = newContent;
  this.isEdited = true;
  this.editedAt = new Date();
  return this.save();
};

// Method to soft delete a comment
feedCommentSchema.methods.softDelete = function() {
  this.status = 'deleted';
  return this.save();
};

// Pre-save middleware to validate content
feedCommentSchema.pre('save', function() {
  if (this.content && this.content.trim().length === 0) {
    throw new Error('Comment content cannot be empty');
  }
});

module.exports = mongoose.model('FeedComment', feedCommentSchema);
