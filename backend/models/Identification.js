const mongoose = require('mongoose');

const identificationSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  plant: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Plant',
    required: true
  },
  photoUrl: {
    type: String,
    default: null
  },
  confidence: {
    type: Number,
    min: 0,
    max: 1,
    required: true
  },
  source: {
    type: String,
    enum: ['plantnet', 'similarity', 'crowdsourced'],
    default: 'plantnet'
  },
  userCorrection: {
    type: String,
    default: null
  },
  location: {
    lat: Number,
    lng: Number
  },
  notes: {
    type: String,
    default: ''
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Index pour les requêtes fréquentes
identificationSchema.index({ user: 1, createdAt: -1 });
identificationSchema.index({ plant: 1 });

module.exports = mongoose.model('Identification', identificationSchema);