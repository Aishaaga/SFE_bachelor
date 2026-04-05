const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();
console.log('🔑 Clé API chargée:', process.env.PLANTNET_API_KEY ? 'OUI (' + process.env.PLANTNET_API_KEY.substring(0, 10) + '...)' : 'NON (manquante)');

// Import des routes
const identifyRoutes = require('./routes/identify');
const authRoutes = require('./routes/auth');
const identificationsRoutes = require('./routes/identifications');

const app = express();
const PORT = process.env.PORT || 3000;

// MIDDLEWARE
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CONNEXION À MONGODB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('MongoDB connecté'))
  .catch(err => console.error('Erreur MongoDB:', err));

// ROUTES
app.use('/api/identify', identifyRoutes);
app.use('/api', authRoutes);  // /api/register, /api/login
app.use('/api', identificationsRoutes);  // /api/save-identification, etc.

// Route de test
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Backend SFE fonctionne' });
});

// Route 404
app.use((req, res) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

// DÉMARRAGE
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
  console.log(`📡 Endpoint identification: http://localhost:${PORT}/api/identify`);
  console.log(`🔐 Endpoints auth: /api/register, /api/login`);
  console.log(`📜 Endpoints historique: /api/my-identifications`);
});