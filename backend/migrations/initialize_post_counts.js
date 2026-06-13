const mongoose = require('mongoose');
const FeedPost = require('../models/FeedPost');
const FeedLike = require('../models/FeedLike');
const FeedComment = require('../models/FeedComment');

// MongoDB connection string - update this to match your config
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/sfe';

async function migrate() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Find all posts
    const posts = await FeedPost.find({});
    console.log(`Found ${posts.length} posts`);

    // Update each post with accurate counts
    for (const post of posts) {
      const likeCount = await FeedLike.getLikeCount(post._id);
      const commentCount = await FeedComment.getCommentCount(post._id);

      post.likeCount = likeCount;
      post.commentCount = commentCount;
      await post.save();

      console.log(`Updated post ${post._id}: likes=${likeCount}, comments=${commentCount}`);
    }

    console.log('Migration completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

migrate();
