const mongoose = require('mongoose');
const FeedComment = require('../models/FeedComment');

// MongoDB connection string - update this to match your config
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/sfe';

async function migrate() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Find all comments that don't have isAnonymous field
    const comments = await FeedComment.find({ isAnonymous: { $exists: false } });
    console.log(`Found ${comments.length} comments without isAnonymous field`);

    // Update each comment
    for (const comment of comments) {
      comment.isAnonymous = false;
      comment.anonymousId = null;
      await comment.save();
      console.log(`Updated comment ${comment._id}`);
    }

    console.log('Migration completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

migrate();
