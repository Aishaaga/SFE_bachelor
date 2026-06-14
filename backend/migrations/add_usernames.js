const mongoose = require('mongoose');
const User = require('../models/User');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/sfe');

async function addUsernames() {
  try {
    console.log('Starting migration: Add usernames to existing users...');

    // Find all users without a username
    const usersWithoutUsername = await User.find({ username: { $exists: false } });
    console.log(`Found ${usersWithoutUsername.length} users without username`);

    for (const user of usersWithoutUsername) {
      // Generate username from email (part before @)
      let baseUsername = user.email.split('@')[0];
      // Remove special characters and make lowercase
      baseUsername = baseUsername.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();

      // Ensure minimum length of 3
      if (baseUsername.length < 3) {
        baseUsername = baseUsername.padEnd(3, '0');
      }

      // Ensure maximum length of 30
      if (baseUsername.length > 30) {
        baseUsername = baseUsername.substring(0, 30);
      }

      // Check if username already exists and make it unique
      let username = baseUsername;
      let counter = 1;

      while (await User.findOne({ username })) {
        username = `${baseUsername}${counter}`;
        counter++;

        // Ensure the new username doesn't exceed 30 characters
        if (username.length > 30) {
          username = `${baseUsername.substring(0, 30 - counter.toString().length)}${counter}`;
        }
      }

      // Use direct update to bypass pre-save hook
      await User.updateOne({ _id: user._id }, { username: username });
      console.log(`Added username "${username}" to user ${user.email}`);
    }

    console.log('Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

addUsernames();
