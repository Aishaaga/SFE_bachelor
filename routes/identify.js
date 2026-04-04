// routes/identify.js
const express = require('express');
const multer = require('multer');
const path = require('path');
const { identifyPlant } = require('../services/plantnet');

const router = express.Router();

// Configuration de multer pour l'upload temporaire
const storage = multer.memoryStorage(); // Stocke en mémoire (pas sur disque)
const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB max
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Seules les images sont autorisées'));
    }
  }
});

// Endpoint POST /identify
router.post('/', upload.single('photo'), async (req, res) => {
  try {
    // Vérifier qu'une photo a bien été envoyée
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        message: 'Aucune photo fournie' 
      });
    }
    
    console.log(`📸 Photo reçue: ${req.file.originalname} (${req.file.size} bytes)`);
    
    // Identifier la plante via Pl@ntNet
    const result = await identifyPlant(req.file.buffer, req.file.originalname);
    
    if (!result.success) {
      return res.status(400).json(result);
    }
    
    // Retourner le résultat
    res.json({
      success: true,
      plant: result.plant,
    });
    
  } catch (error) {
    console.error('Erreur:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur interne du serveur' 
    });
  }
});

module.exports = router;