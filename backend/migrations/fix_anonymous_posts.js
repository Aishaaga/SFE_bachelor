// Migration to fix anonymous posts by restoring userId from Identification model
// Run this script to update old anonymous posts that have userId: null

const mongoose = require('mongoose');
const FeedPost = require('../models/FeedPost');
const Identification = require('../models/Identification');
const User = require('../models/User');
require('dotenv').config();

async function fixAnonymousPosts() {
  try {
    // Connect to database
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/sfe');
    console.log('Connected to database');

    // Find all FeedPosts with userId: null and identificationId
    const anonymousPosts = await FeedPost.find({
      userId: null,
      identificationId: { $ne: null }
    });

    console.log(`Found ${anonymousPosts.length} anonymous posts with identificationId`);

    let updatedCount = 0;
    let notFoundCount = 0;

    for (const post of anonymousPosts) {
      try {
        // Fetch the identification to get the user
        const identification = await Identification.findById(post.identificationId).populate('user', 'name email username');
        
        if (identification && identification.user) {
          // Update the post with the user from identification
          post.userId = identification.user._id;
          await post.save();
          console.log(`✓ Updated post ${post._id} with user ${identification.user.name} (${identification.user.email})`);
          updatedCount++;
        } else {
          console.log(`✗ Could not find user for post ${post._id} (identification: ${post.identificationId})`);
          notFoundCount++;
        }
      } catch (err) {
        console.log(`✗ Error processing post ${post._id}:`, err.message);
      }
    }

    console.log('\n=== Summary ===');
    console.log(`Total anonymous posts found: ${anonymousPosts.length}`);
    console.log(`Successfully updated: ${updatedCount}`);
    console.log(`Could not find user: ${notFoundCount}`);
    console.log(`Failed: ${anonymousPosts.length - updatedCount - notFoundCount}`);

    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

fixAnonymousPosts();
