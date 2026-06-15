const express = require('express');
const router = express.Router();
const FeedPost = require('../models/FeedPost');
const FeedLike = require('../models/FeedLike');
const TranslationVote = require('../models/TranslationVote');
const Plant = require('../models/Plant');
const Identification = require('../models/Identification');
const ContentReport = require('../models/ContentReport');
const HiddenContent = require('../models/HiddenContent');
const auth = require('../middleware/auth');

// POST /api/feed/share - Share a discovery to the community feed
router.post('/share', auth, async (req, res) => {
  try {
    const {
      type = 'identification',
      plantId,
      plantName,
      scientificName,
      imageUrl,
      identificationId,
      suggestedDarija,
      suggestedTamazight,
      isAnonymous,
      location
    } = req.body;

    // Debug logging
    console.log('DEBUG: Feed share request received:');
    console.log('  plantId:', plantId);
    console.log('  plantName:', plantName);
    console.log('  scientificName:', scientificName);
    console.log('  imageUrl:', imageUrl);
    console.log('  identificationId:', identificationId);
    console.log('  suggestedDarija:', suggestedDarija);
    console.log('  suggestedTamazight:', suggestedTamazight);
    console.log('  isAnonymous:', isAnonymous);
    console.log('  location:', location);

    // Validate required fields
    if (!plantId || !plantName || !scientificName) {
      console.log('DEBUG: Validation failed - missing required fields');
      console.log('  plantId exists:', !!plantId);
      console.log('  plantName exists:', !!plantName);
      console.log('  scientificName exists:', !!scientificName);
      return res.status(400).json({
        success: false,
        message: 'Plant information is required'
      });
    }

    // Validate location
    if (!location || !location.level) {
      return res.status(400).json({
        success: false,
        message: 'Location information is required'
      });
    }

    // Generate a valid ObjectId if plantId is unknown
    let finalPlantId = plantId;
    if (plantId === 'unknown' || !plantId) {
      // Generate a temporary ObjectId based on plant name and timestamp
      const { ObjectId } = require('mongoose');
      const timestamp = Date.now();
      const plantHash = plantName.substring(0, 8).replace(/\s/g, '').toLowerCase();
      finalPlantId = new ObjectId(timestamp.toString(16) + plantHash.padEnd(16, '0'));
    }
    
    console.log('DEBUG: Final plantId for database:', finalPlantId);

    // Get the actual image URL from identification if identificationId is provided
    let actualImageUrl = imageUrl;
    if (type === 'identification' && identificationId) {
      try {
        const Identification = require('../models/Identification');
        const identification = await Identification.findById(identificationId);
        if (identification && identification.photoUrl) {
          actualImageUrl = identification.photoUrl;
          console.log('DEBUG: Using photoUrl from identification:', actualImageUrl);
          console.log('DEBUG: Overriding provided imageUrl:', imageUrl);
        }
      } catch (error) {
        console.log('DEBUG: Could not fetch identification for photoUrl:', error.message);
        console.log('DEBUG: Falling back to provided imageUrl:', imageUrl);
      }
    }

    // Create the feed post
    const feedPost = new FeedPost({
      type,
      userId: isAnonymous ? null : req.userId,
      isAnonymous,
      plantId: finalPlantId,
      plantName,
      scientificName,
      imageUrl: type === 'identification' ? actualImageUrl : undefined,
      identificationId: type === 'identification' ? identificationId : undefined,
      suggestedDarija: suggestedDarija,
      suggestedTamazight: suggestedTamazight,
      location: {
        level: location.level,
        country: location.country || 'Morocco',
        city: location.level === 'city' ? location.city : undefined
      }
    });

    await feedPost.save();

    res.status(201).json({
      success: true,
      message: 'Discovery shared successfully!',
      data: feedPost
    });

  } catch (error) {
    console.error('Error sharing to feed:', error);
    res.status(500).json({
      success: false,
      message: 'Error sharing discovery'
    });
  }
});

// GET /api/feed - Get all feed posts
router.get('/', async (req, res) => {
  try {
    const {
      type,
      page = 1,
      limit = 20,
      locationLevel,
      city
    } = req.query;

    // Get user ID from auth header if available
    const authHeader = req.headers.authorization;
    let userId = null;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      try {
        const token = authHeader.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
        userId = decoded.userId;
      } catch (e) {
        // Token invalid, continue without user ID
      }
    }

    // Build query
    // Show active, approved, and refused posts (refused translations should appear in feed with badge)
    let query;
    if (type === 'translation_suggestion') {
      // For translation suggestions, show active, approved, and refused
      query = {
        type: 'translation_suggestion',
        status: { $in: ['active', 'approved', 'refused'] }
      };
    } else if (type) {
      // For specific other types, only show active
      query = { status: 'active', type: type };
    } else {
      // When no type specified, show all active posts plus approved and refused translation suggestions
      query = {
        $or: [
          { status: 'active' },
          { type: 'translation_suggestion', status: 'approved' },
          { type: 'translation_suggestion', status: 'refused' }
        ]
      };
    }

    if (locationLevel) {
      query['location.level'] = locationLevel;
      if (locationLevel === 'city' && city) {
        query['location.city'] = city;
      }
    }

    // Get hidden content IDs to exclude from feed
    const hiddenContent = await HiddenContent.find({});
    const hiddenContentIds = new Set(hiddenContent.map(h => h.contentId.toString()));

    // Add exclusion for hidden content
    if (hiddenContentIds.size > 0) {
      query._id = { $nin: Array.from(hiddenContentIds) };
    }

    const posts = await FeedPost.find(query)
      .populate('userId', 'email username')
      .populate('plantId', 'name scientificName family')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    // If user is authenticated, check liked status for each post
    if (userId) {
      const postIds = posts.map(post => post._id);
      const userLikes = await FeedLike.find({
        feedPostId: { $in: postIds },
        userId: userId
      });

      const likedPostIds = new Set(userLikes.map(like => like.feedPostId.toString()));

      // Add liked status to each post
      posts.forEach(post => {
        post._doc.isLiked = likedPostIds.has(post._id.toString());
      });

      // Check vote status for translation suggestion posts
      const translationPosts = posts.filter(post => post.type === 'translation_suggestion');
      if (translationPosts.length > 0) {
        const translationPostIds = translationPosts.map(post => post._id);
        const userVotes = await TranslationVote.find({
          translationSuggestionId: { $in: translationPostIds },
          userId: userId
        });

        // Create a map of post ID to vote type
        const voteMap = {};
        userVotes.forEach(vote => {
          voteMap[vote.translationSuggestionId.toString()] = vote.voteType;
        });

        // Add vote type to each translation post
        translationPosts.forEach(post => {
          post._doc.userVoteType = voteMap[post._id.toString()] || null;
        });
      }
    }

    const total = await FeedPost.countDocuments(query);

    res.json({
      success: true,
      data: posts,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Error fetching feed posts:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching feed posts'
    });
  }
});

// GET /api/feed/:id - Get a specific feed post
router.get('/:id', async (req, res) => {
  try {
    const post = await FeedPost.findById(req.params.id)
      .populate('userId', 'email username')
      .populate('plantId', 'name scientificName family')
      .populate('identificationId');

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    // Get user ID from auth header if available
    const authHeader = req.headers.authorization;
    let userId = null;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      try {
        const token = authHeader.split(' ')[1];
        const jwt = require('jsonwebtoken');
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
        userId = decoded.userId;
      } catch (e) {
        // Token invalid, continue without user ID
      }
    }

    // If user is authenticated, check liked and vote status
    if (userId) {
      // Check liked status
      const userLike = await FeedLike.findOne({
        feedPostId: post._id,
        userId: userId
      });
      post._doc.isLiked = !!userLike;

      // Check vote status for translation suggestions
      if (post.type === 'translation_suggestion') {
        const userVote = await TranslationVote.findOne({
          translationSuggestionId: post._id,
          userId: userId
        });
        post._doc.userVoteType = userVote ? userVote.voteType : null;
      }
    }

    res.json({
      success: true,
      data: post
    });

  } catch (error) {
    console.error('Error fetching feed post:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching feed post'
    });
  }
});

// POST /api/feed/:id/like - Like a feed post
router.post('/:id/like', auth, async (req, res) => {
  try {
    const post = await FeedPost.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    post.likes += 1;
    await post.save();

    res.json({
      success: true,
      message: 'Post liked successfully',
      likes: post.likes
    });

  } catch (error) {
    console.error('Error liking post:', error);
    res.status(500).json({
      success: false,
      message: 'Error liking post'
    });
  }
});

// POST /api/feed/:id/report - Report a feed post
router.post('/:id/report', auth, async (req, res) => {
  try {
    const { reason } = req.body;
    const post = await FeedPost.findById(req.params.id);

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    if (!reason || reason.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Report reason is required'
      });
    }

    // Determine content type based on post type
    const contentType = post.type === 'identification' ? 'identification' : 'translation';

    // Check if user already reported this content
    const existingReport = await ContentReport.findOne({
      contentType,
      contentId: post._id,
      reportedBy: req.userId
    });

    if (existingReport) {
      return res.status(400).json({
        success: false,
        message: 'You have already reported this content'
      });
    }

    // Create report
    const report = new ContentReport({
      contentType,
      contentId: post._id,
      reportedBy: req.userId,
      reason: reason.trim(),
      status: 'pending'
    });

    await report.save();

    res.json({
      success: true,
      message: 'Content reported successfully'
    });

  } catch (error) {
    console.error('Error reporting post:', error);
    res.status(500).json({
      success: false,
      message: 'Error reporting post'
    });
  }
});

module.exports = router;
