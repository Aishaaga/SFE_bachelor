const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();
console.log(' Clé API chargée:', process.env.PLANTNET_API_KEY ? 'OUI (' + process.env.PLANTNET_API_KEY.substring(0, 10) + '...)' : 'NON (manquante)');

// Import des routes
const gbifRoutes = require('./routes/gbif');
const identifyRoutes = require('./routes/identify');
const authRoutes = require('./routes/auth');
const identificationsRoutes = require('./routes/identifications');
const translationSuggestionsRoutes = require('./routes/translation-suggestions');
const adminRoutes = require('./routes/admin');
const feedRoutes = require('./routes/feed');
const feedLikesRoutes = require('./routes/feed-likes');
const feedCommentsRoutes = require('./routes/feed-comments');
const translationVotesRoutes = require('./routes/translation-votes');
console.log('✅ Admin routes imported');

const app = express();
const PORT = process.env.PORT || 3000;

// MIDDLEWARE
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir les fichiers statiques (uploads)
app.use('/uploads', express.static('uploads'));

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
app.use('/api/translation-suggestions', translationSuggestionsRoutes);  // /api/translation-suggestions (auth requise)
app.use('/api', identificationsRoutes);  // /api/save-identification, etc. (avec auth)
app.use('/api/feed', feedRoutes);  // Feed endpoints
app.use('/api/feed-likes', feedLikesRoutes);  // Feed likes endpoints
app.use('/api/feed-comments', feedCommentsRoutes);  // Feed comments endpoints
app.use('/api/translation-votes', translationVotesRoutes);  // Translation votes endpoints
app.use('/api/admin', adminRoutes);  // Admin endpoints
console.log('✅ Admin routes mounted at /api/admin');

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
app.listen(PORT, '0.0.0.0', () => {
  console.log(` Serveur démarré sur http://localhost:${PORT}`);
  console.log(` Accessible via IP: http://192.168.0.182:${PORT}`);
  console.log(` Endpoint identification: http://localhost:${PORT}/api/identify`);
  console.log(` Endpoints auth: /api/register, /api/login`);
  console.log(` Endpoints historique: /api/my-identifications`);
  console.log(` Admin endpoints: /api/admin/pending, /api/admin/stats`);
});