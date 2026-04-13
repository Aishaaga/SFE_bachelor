const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();
console.log('🔑 Clé API chargée:', process.env.PLANTNET_API_KEY ? 'OUI (' + process.env.PLANTNET_API_KEY.substring(0, 10) + '...)' : 'NON (manquante)');

// Import des routes
const gbifRoutes = require('./routes/gbif');
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

// Route de test
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Backend SFE fonctionne' });
});

// ROUTES
app.use('/api/gbif', gbifRoutes);
app.use('/api/identify', identifyRoutes);
app.use('/api', authRoutes);  // /api/register, /api/login
app.use('/api', identificationsRoutes);  // /api/save-identification, etc.




// Route 404
app.use((req, res) => {
  res.status(404).json({ message: 'Route non trouvée' });
});

// ROUTE DE DEBUG - À SUPPRIMER PLUS TARD
app.get('/api/debug/user/:email', async (req, res) => {
  const User = require('./models/User');
  const user = await User.findOne({ email: req.params.email });
  if (!user) return res.json({ error: 'User not found' });
  
  res.json({
    email: user.email,
    passwordLength: user.password.length,
    passwordStart: user.password.substring(0, 20) + '...',
    isHashed: user.password.startsWith('$2b$')
  });
});

// DÉMARRAGE
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
  console.log(`📡 Endpoint identification: http://localhost:${PORT}/api/identify`);
  console.log(`🔐 Endpoints auth: /api/register, /api/login`);
  console.log(`📜 Endpoints historique: /api/my-identifications`);
});