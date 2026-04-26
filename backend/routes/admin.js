const express = require('express');
const router = express.Router();
const adminAuth = require('../middleware/adminAuth');
const path = require('path');

// Route pour servir la page de login admin (sans authentification)
router.get('/login', (req, res) => {
  try {
    const loginPath = path.join(__dirname, '../admin/login.html');
    res.sendFile(loginPath);
  } catch (error) {
    console.error('Erreur lors de la livraison de la page de login:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors du chargement de la page de login.'
    });
  }
});

// Route pour servir la page de logs admin (sans authentification - le JavaScript gère l'auth)
router.get('/logs', (req, res) => {
  try {
    const logsPath = path.join(__dirname, '../admin/index.html');
    res.sendFile(logsPath);
  } catch (error) {
    console.error('Erreur lors de la livraison de la page de logs:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors du chargement de la page de logs.'
    });
  }
});

// Route pour servir le dashboard admin
router.get('/dashboard', adminAuth, (req, res) => {
  try {
    const dashboardPath = path.join(__dirname, '../admin/dashboard.html');
    res.sendFile(dashboardPath);
  } catch (error) {
    console.error('Erreur lors de la livraison du dashboard:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors du chargement du dashboard.'
    });
  }
});

// Route pour obtenir les logs (API endpoint)
router.get('/api/logs', adminAuth, async (req, res) => {
  try {
    // Pour l'instant, retourner des données de test
    // En production, vous implémenteriez la récupération réelle des logs
    const mockLogs = [
      {
        id: 1,
        timestamp: new Date('2024-04-23T10:30:00'),
        level: 'error',
        source: 'server',
        message: 'Erreur de connexion à la base de données MongoDB',
        details: 'Connection timeout after 30000ms',
        userId: null
      },
      {
        id: 2,
        timestamp: new Date('2024-04-23T10:25:00'),
        level: 'warning',
        source: 'auth',
        message: 'Tentative de connexion échouée',
        details: 'Email: admin@example.com - IP: 192.168.1.100',
        userId: 'user123'
      },
      {
        id: 3,
        timestamp: new Date('2024-04-23T10:20:00'),
        level: 'info',
        source: 'api',
        message: 'Nouvelle identification plante créée',
        details: 'Plante ID: plant456 - Espèce: Rosa canina',
        userId: 'user456'
      },
      {
        id: 4,
        timestamp: new Date('2024-04-23T10:15:00'),
        level: 'success',
        source: 'external',
        message: 'API PlantNet répondue avec succès',
        details: '200 OK - Temps de réponse: 245ms',
        userId: null
      },
      {
        id: 5,
        timestamp: new Date('2024-04-23T10:10:00'),
        level: 'debug',
        source: 'database',
        message: 'Requête MongoDB exécutée',
        details: 'Collection: users - Opération: find - Temps: 12ms',
        userId: null
      }
    ];

    res.json({
      success: true,
      data: mockLogs,
      total: mockLogs.length
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des logs:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des logs.'
    });
  }
});

// Route pour obtenir les statistiques admin
router.get('/api/stats', adminAuth, async (req, res) => {
  try {
    // Statistiques de test - à implémenter avec de vraies données
    const stats = {
      users: {
        total: 150,
        active: 89,
        newThisMonth: 23
      },
      identifications: {
        total: 1245,
        today: 45,
        thisWeek: 234
      },
      plants: {
        total: 890,
        validated: 678,
        pending: 212
      },
      system: {
        uptime: '15 jours 4 heures',
        memoryUsage: '45%',
        diskUsage: '23%'
      }
    };

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des statistiques:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques.'
    });
  }
});

// Route pour obtenir la liste des utilisateurs
router.get('/api/users', adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const users = await User.find({})
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({
      success: true,
      data: users,
      total: users.length
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des utilisateurs:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des utilisateurs.'
    });
  }
});

// Route pour promouvoir un utilisateur en admin
router.put('/api/users/:id/promote', adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const userId = req.params.id;

    const user = await User.findByIdAndUpdate(
      userId,
      { role: 'admin' },
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé.'
      });
    }

    res.json({
      success: true,
      message: 'Utilisateur promu avec succès.',
      data: user
    });
  } catch (error) {
    console.error('Erreur lors de la promotion de l\'utilisateur:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la promotion de l\'utilisateur.'
    });
  }
});

// Route pour rétrograder un admin en utilisateur
router.put('/api/users/:id/demote', adminAuth, async (req, res) => {
  try {
    const User = require('../models/User');
    const userId = req.params.id;

    // Empêcher la rétrogradation de soi-même
    if (userId === req.userId) {
      return res.status(400).json({
        success: false,
        message: 'Vous ne pouvez pas rétrograder votre propre compte.'
      });
    }

    const user = await User.findByIdAndUpdate(
      userId,
      { role: 'user' },
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé.'
      });
    }

    res.json({
      success: true,
      message: 'Utilisateur rétrogradé avec succès.',
      data: user
    });
  } catch (error) {
    console.error('Erreur lors de la rétrogradation de l\'utilisateur:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la rétrogradation de l\'utilisateur.'
    });
  }
});

module.exports = router;