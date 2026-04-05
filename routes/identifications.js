const express = require('express');
const authMiddleware = require('../middleware/auth');
const Identification = require('../models/Identification');
const Plant = require('../models/Plant');

const router = express.Router();

// Toutes les routes ici nécessitent d'être authentifié
router.use(authMiddleware);

// POST /api/save-identification - Sauvegarder une identification
router.post('/save-identification', async (req, res) => {
  try {
    const { 
      plantName,        // Nom de la plante (ex: "Flamingo-lily")
      scientificName,
      family,
      confidence,
      source = 'plantnet',
      photoUrl,
      notes
    } = req.body;
    
    // 1. Trouver ou créer la plante dans la base
    let plant = await Plant.findOne({ name: plantName });
    
    if (!plant) {
      // Créer une nouvelle plante
      plant = new Plant({
        name: plantName,
        scientificName: scientificName || '',
        family: family || '',
        source: source,
        identificationCount: 0
      });
      await plant.save();
    }
    
    // 2. Mettre à jour les statistiques de la plante
    plant.identificationCount += 1;
    plant.confidenceAvg = (plant.confidenceAvg * (plant.identificationCount - 1) + confidence) / plant.identificationCount;
    await plant.save();
    
    // 3. Créer l'identification
    const identification = new Identification({
      user: req.userId,
      plant: plant._id,
      confidence: confidence,
      source: source,
      photoUrl: photoUrl,
      notes: notes || ''
    });
    
    await identification.save();
    
    res.status(201).json({
      success: true,
      message: 'Identification sauvegardée',
      identification: {
        id: identification._id,
        plant: plant,
        confidence: confidence,
        createdAt: identification.createdAt
      }
    });
    
  } catch (error) {
    console.error('Erreur save identification:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la sauvegarde'
    });
  }
});

// GET /api/my-identifications - Voir son historique
router.get('/my-identifications', async (req, res) => {
  try {
    // Récupérer les identifications de l'utilisateur
    const identifications = await Identification.find({ user: req.userId })
      .populate('plant')  // Remplacer l'ID plante par ses données
      .sort({ createdAt: -1 })  // Les plus récentes d'abord
      .limit(100);  // Maximum 100 résultats
    
    res.json({
      success: true,
      count: identifications.length,
      identifications: identifications.map(ident => ({
        id: ident._id,
        plant: {
          name: ident.plant.name,
          scientificName: ident.plant.scientificName,
          family: ident.plant.family,
          localName: ident.plant.localName
        },
        confidence: ident.confidence,
        source: ident.source,
        notes: ident.notes,
        date: ident.createdAt
      }))
    });
    
  } catch (error) {
    console.error('Erreur get identifications:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération de l\'historique'
    });
  }
});

// GET /api/identifications/:id - Détail d'une identification
router.get('/identifications/:id', async (req, res) => {
  try {
    const identification = await Identification.findOne({
      _id: req.params.id,
      user: req.userId  // Vérifier que c'est bien à l'utilisateur
    }).populate('plant');
    
    if (!identification) {
      return res.status(404).json({
        success: false,
        message: 'Identification non trouvée'
      });
    }
    
    res.json({
      success: true,
      identification
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération'
    });
  }
});

// DELETE /api/identifications/:id - Supprimer une identification
router.delete('/identifications/:id', async (req, res) => {
  try {
    const result = await Identification.deleteOne({
      _id: req.params.id,
      user: req.userId
    });
    
    if (result.deletedCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'Identification non trouvée'
      });
    }
    
    res.json({
      success: true,
      message: 'Identification supprimée'
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression'
    });
  }
});

module.exports = router;