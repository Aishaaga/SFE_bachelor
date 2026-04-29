const express = require('express');
const router = express.Router();
const FeedPost = require('../models/FeedPost');
const Plant = require('../models/Plant');
const Identification = require('../models/Identification');
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

    // Create the feed post
    const feedPost = new FeedPost({
      type,
      userId: isAnonymous ? null : req.user.id,
      isAnonymous,
      plantId,
      plantName,
      scientificName,
      imageUrl: type === 'identification' ? imageUrl : undefined,
      identificationId: type === 'identification' ? identificationId : undefined,
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

    // Build query
    const query = { status: 'active' };
    
    if (type) {
      query.type = type;
    }
    
    if (locationLevel) {
      query['location.level'] = locationLevel;
      if (locationLevel === 'city' && city) {
        query['location.city'] = city;
      }
    }

    const posts = await FeedPost.find(query)
      .populate('userId', 'email')
      .populate('plantId', 'name scientificName family')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

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
      .populate('userId', 'email')
      .populate('plantId', 'name scientificName family')
      .populate('identificationId');

    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
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

// POST /api/feed/:id/flag - Flag a feed post
router.post('/:id/flag', auth, async (req, res) => {
  try {
    const post = await FeedPost.findById(req.params.id);
    
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    post.status = 'flagged';
    await post.save();

    res.json({
      success: true,
      message: 'Post flagged successfully'
    });

  } catch (error) {
    console.error('Error flagging post:', error);
    res.status(500).json({
      success: false,
      message: 'Error flagging post'
    });
  }
});

module.exports = router;
