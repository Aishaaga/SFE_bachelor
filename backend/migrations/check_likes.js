const mongoose = require('mongoose');
const FeedPost = require('../models/FeedPost');
const FeedLike = require('../models/FeedLike');

// MongoDB connection string - update this to match your config
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/sfe';

async function check() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Find all posts
    const posts = await FeedPost.find({});
    console.log(`\nFound ${posts.length} posts\n`);

    for (const post of posts) {
      const likeCount = await FeedLike.getLikeCount(post._id);
      const likesInDb = await FeedLike.find({ feedPostId: post._id });

      console.log(`Post ${post._id}:`);
      console.log(`  likeCount in post: ${post.likeCount}`);
      console.log(`  likes in FeedLike: ${likeCount}`);
      console.log(`  Actual like documents: ${likesInDb.length}`);

      if (likesInDb.length > 0) {
        console.log(`  Like documents:`);
        likesInDb.forEach(like => {
          console.log(`    - userId: ${like.userId}, createdAt: ${like.createdAt}`);
        });
      }

      // Check for mismatch
      if (post.likeCount !== likeCount) {
        console.log(`  ⚠️  MISMATCH! Fixing...`);
        post.likeCount = likeCount;
        post.likes = likeCount;
        await post.save();
        console.log(`  ✓ Fixed`);
      }

      console.log('');
    }

    console.log('Check completed');
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

check();
