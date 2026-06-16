const express = require('express');
const multer = require('multer');
const path = require('path');
const { identifyPlant} = require('../services/plantnet');
const authMiddleware = require('../middleware/auth');
const Identification = require('../models/Identification');
const Plant = require('../models/Plant');
const axios = require('axios');

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'plant-' + uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    console.log('=== WHAT FLUTTER SENT ===');
    console.log('Field name:', file.fieldname);
    console.log('File name:', file.originalname);
    console.log('MIME type:', file.mimetype);
    console.log('File size:', file.size, 'bytes');
    
    const allowedTypes = /jpeg|jpg|png|heic/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    console.log('Extension valid?', extname);
    console.log('MIME type valid?', mimetype);
    console.log('========================');
    
    if (mimetype && extname) {
      console.log('IMAGE ACCEPTED');
      return cb(null, true);
    } else {
      console.log('IMAGE REJECTED');
      cb(new Error('Seules les images sont autorisées'));
    }
  }
});

const PLANTNET_TIMEOUT = 90000; // 90 seconds max

// POST /api/identify (protected by authentication)
router.post('/', authMiddleware, upload.single('image'), async (req, res) => {
  try {
    let imageBuffer;
    let photoUrl;
    let filename;

    // Check if image is provided as file or Cloudinary URL
    if (req.file) {
      // File upload
      console.log('Photo received (file): ' + req.file.originalname + ' (' + req.file.size + ' bytes)');
      const fs = require('fs');
      imageBuffer = fs.readFileSync(req.file.path);
      photoUrl = '/uploads/' + req.file.filename;
      filename = req.file.originalname;
    } else if (req.body.imageUrl) {
      // Cloudinary URL
      console.log('Photo received (Cloudinary URL): ' + req.body.imageUrl);
      const response = await axios.get(req.body.imageUrl, { responseType: 'arraybuffer' });
      imageBuffer = Buffer.from(response.data, 'binary');
      photoUrl = req.body.imageUrl;
      filename = 'cloudinary-image.jpg';
    } else {
      return res.status(400).json({ 
        success: false, 
        message: 'Aucune photo fournie' 
      });
    }
    
    // Call PlantNet API
    const result = await identifyPlant(imageBuffer, filename);
    
    if (!result.success) {
      return res.status(400).json(result);
    }
    
    // Save identification automatically
    try {
      // Find or create plant
      let plant = await Plant.findOne({ name: result.plant.name });
      
      if (!plant) {
        plant = new Plant({
          name: result.plant.name,
          scientificName: result.plant.scientificName,
          family: result.plant.family,
          source: 'plantnet',
          identificationCount: 0
        });
        await plant.save();
      }
      
      // Update statistics
      plant.identificationCount += 1;
      await plant.save();
      
      // Create identification
      console.log('DEBUG: Saving photoUrl:', photoUrl);
      
      const identification = new Identification({
        user: req.userId,
        plant: plant._id,
        confidence: result.plant.confidence,
        source: 'plantnet',
        photoUrl: photoUrl
      });
      await identification.save();
      console.log('DEBUG: Identification saved with photoUrl:', photoUrl);
      
      result.saved = true;
      result.identificationId = identification._id;
      
    } catch (saveError) {
      console.error('Error during automatic save:', saveError);
      result.saved = false;
    }
    
    res.json(result);
    
  } catch (error) {
    console.error('Error:', error.message);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur lors de l\'identification' 
    });
  }
});

module.exports = router;
