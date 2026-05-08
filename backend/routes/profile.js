const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const FeedPost = require('../models/FeedPost');
const TranslationSuggestion = require('../models/TranslationSuggestion');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/profile - Get current user profile
router.get('/', auth, async (req, res) => {
  console.log('🔥 PROFILE ROUTE HIT!');
  console.log('🔥 Headers:', req.headers);
  console.log('🔥 User ID from auth:', req.userId);
  try {
    const user = await User.findById(req.userId).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }

    // Calculate actual statistics
    const [contributionsCount, identificationsCount, translationSuggestionsCount] = await Promise.all([
      FeedPost.countDocuments({ userId: user._id }),
      FeedPost.countDocuments({ userId: user._id, type: 'identification' }),
      TranslationSuggestion.countDocuments({ userId: user._id })
    ]);

    // Update user statistics if they're out of sync
    if (user.contributionsCount !== contributionsCount || 
        user.identificationsCount !== identificationsCount || 
        user.translationSuggestionsCount !== translationSuggestionsCount) {
      user.contributionsCount = contributionsCount;
      user.identificationsCount = identificationsCount;
      user.translationSuggestionsCount = translationSuggestionsCount;
      await user.save();
    }

    res.json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        name: user.name,
        bio: user.bio,
        location: user.location,
        profileImage: user.profileImage,
        contributionsCount: user.contributionsCount,
        identificationsCount: user.identificationsCount,
        translationSuggestionsCount: user.translationSuggestionsCount,
        createdAt: user.createdAt
      }
    });
    
  } catch (error) {
    console.error('Erreur get profile:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération du profil'
    });
  }
});

// PUT /api/profile - Update current user profile
router.put('/', auth, async (req, res) => {
  try {
    const { name, bio, location, profileImage } = req.body;
    
    const user = await User.findById(req.userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }

    // Update allowed fields
    if (name !== undefined) user.name = name;
    if (bio !== undefined) user.bio = bio;
    if (location !== undefined) user.location = location;
    if (profileImage !== undefined) user.profileImage = profileImage;

    await user.save();

    res.json({
      success: true,
      message: 'Profil mis à jour avec succès',
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        name: user.name,
        bio: user.bio,
        location: user.location,
        profileImage: user.profileImage,
        contributionsCount: user.contributionsCount,
        identificationsCount: user.identificationsCount,
        translationSuggestionsCount: user.translationSuggestionsCount,
        createdAt: user.createdAt
      }
    });
    
  } catch (error) {
    console.error('Erreur update profile:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour du profil'
    });
  }
});

module.exports = router;
