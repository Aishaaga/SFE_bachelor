const mongoose = require('mongoose');

const plantSchema = new mongoose.Schema({
  // Informations de base (de Pl@ntNet)
  name: {
    type: String,
    required: true
  },
  scientificName: {
    type: String,
    default: ''
  },
  family: {
    type: String,
    default: ''
  },
  
  // Pour le mapping futur (noms locaux)
  localName: {
    type: String,
    default: null
  },
  arabicName: {
    type: String,
    default: null
  },
  
  // Pour les plantes marocaines
  isMoroccanEndemic: {
    type: Boolean,
    default: false
  },
  region: [{
    type: String,
    enum: ['Atlas', 'Rif', 'Sahara', 'Souss', 'Littoral', 'Moyen Atlas']
  }],
  
  // Statistiques
  identificationCount: {
    type: Number,
    default: 0
  },
  confidenceAvg: {
    type: Number,
    default: 0
  },
  
  // Source
  source: {
    type: String,
    enum: ['plantnet', 'admin', 'crowdsourced'],
    default: 'plantnet'
  },
  
  // Métadonnées
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Créer un index pour la recherche rapide
plantSchema.index({ name: 'text', scientificName: 'text', localName: 'text' });

module.exports = mongoose.model('Plant', plantSchema);