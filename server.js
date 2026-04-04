// server.js
const express = require('express');
const cors = require('cors');
require('dotenv').config();
console.log('🔑 Clé API chargée:', process.env.PLANTNET_API_KEY ? 'OUI (' + process.env.PLANTNET_API_KEY.substring(0, 10) + '...)' : 'NON (manquante)');
const identifyRoutes = require('./routes/identify');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Autorise Flutter (et plus tard React) à appeler l'API
app.use(express.json()); // Parse le JSON

// Routes
app.use('/api/identify', identifyRoutes);

// Route de test (pour vérifier que le serveur tourne)
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Backend SFE fonctionne' });
});

// Route 404 pour les endpoints inexistants
app.use( (req, res) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
  console.log(`📡 Endpoint d'identification: http://localhost:${PORT}/api/identify`);
  console.log(`✅ API Pl@ntNet configurée: ${process.env.PLANTNET_API_KEY ? 'OUI' : 'NON (clé manquante)'}`);
});