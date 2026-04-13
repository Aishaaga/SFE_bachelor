const express = require('express');
const multer = require('multer');
const path = require('path');
const axios = require('axios');
const FormData = require('form-data');
const authMiddleware = require('../middleware/auth');
const Identification = require('../models/Identification');
const Plant = require('../models/Plant');

const router = express.Router();

const storage = multer.memoryStorage();
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
      console.log('✅ IMAGE ACCEPTED');
      return cb(null, true);
    } else {
      console.log('❌ IMAGE REJECTED');
      cb(new Error('Seules les images sont autorisées'));
    }
  }
});

const PLANTNET_TIMEOUT = 90000; // 90 seconds max

// Function to identify plant using PlantNet API (ONLY ONE!)
async function callPlantNetAPI(imageBuffer, filename) {
  try {
    console.log('🌿 Preparing PlantNet request...');
    
    const formData = new FormData();
    
    // CRITICAL: Field name MUST be 'images' (plural)
    formData.append('images', imageBuffer, {
      filename: filename,
      contentType: 'image/jpeg'
    });
    
    // Optional parameters
    formData.append('organs', 'leaf');
    formData.append('lang', 'fr');
    
    console.log('📡 Sending to PlantNet API...');
    
    const response = await axios.post(
      'https://my-api.plantnet.org/v2/identify/all',
      formData,
      {
        params: {
          'api-key': process.env.PLANTNET_API_KEY,
        },
        headers: {
          ...formData.getHeaders(),
        },
        timeout: PLANTNET_TIMEOUT,
      }
    );
    
    console.log('✅ PlantNet responded successfully');
    
    // ✅ FIX: Parse PlantNet's actual response format
    if (!response.data || !response.data.results || response.data.results.length === 0) {
      throw new Error('Aucune plante reconnue');
    }
    
    const bestMatch = response.data.results[0];
    const species = bestMatch.species;
    
    // Extract common name (handle multiple languages)
    let commonName = species.commonNames?.[0] || species.scientificNameWithoutAuthor;
    
    return {
      success: true,
      plant: {
        name: commonName,
        scientificName: species.scientificNameWithoutAuthor,
        confidence: bestMatch.score,
        family: species.family?.scientificNameWithoutAuthor || 'Inconnue'
      },
      saved: false
    };
    
  } catch (error) {
    console.error('❌ PlantNet API Error:');
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Data:', error.response.data);
    } else {
      console.error('   Message:', error.message);
    }
    throw error;
  }
}

// POST /api/identify (protégé par authentification)
router.post('/', authMiddleware, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        message: 'Aucune photo fournie' 
      });
    }
    
    console.log(`📸 Photo reçue: ${req.file.originalname} (${req.file.size} bytes)`);
    
    // Call PlantNet API
    const result = await callPlantNetAPI(req.file.buffer, req.file.originalname);
    
    if (!result.success) {
      return res.status(400).json(result);
    }
    
    // Sauvegarder automatiquement l'identification
    try {
      // Trouver ou créer la plante
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
      
      // Mettre à jour les statistiques
      plant.identificationCount += 1;
      await plant.save();
      
      // Créer l'identification
      const identification = new Identification({
        user: req.userId,
        plant: plant._id,
        confidence: result.plant.confidence,
        source: 'plantnet'
      });
      await identification.save();
      
      result.saved = true;
      result.identificationId = identification._id;
      
    } catch (saveError) {
      console.error('Erreur lors de la sauvegarde automatique:', saveError);
      result.saved = false;
    }
    
    return res.json(result);
    
  } catch (error) {
    console.error('Erreur:', error.message);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur lors de l\'identification' 
    });
  }
});

module.exports = router;