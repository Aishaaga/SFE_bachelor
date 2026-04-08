const express = require('express');
const multer = require('multer');
const path = require('path');
const { identifyPlant } = require('../services/plantnet');
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
    
    // Identifier la plante
    const result = await identifyPlant(req.file.buffer, req.file.originalname);
    
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
    
    res.json(result);
    
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur interne du serveur' 
    });
  }
});

module.exports = router;