const jwt = require('jsonwebtoken');
const User = require('../models/User');

const adminAuthMiddleware = async (req, res, next) => {
  try {
    // 1. Récupérer le token du header Authorization
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ 
        success: false, 
        message: 'Accès non autorisé. Token manquant.' 
      });
    }
    
    // 2. Extraire le token (supprimer "Bearer ")
    const token = authHeader.split(' ')[1];
    
    // 3. Vérifier et décoder le token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // 4. Récupérer l'utilisateur depuis la base de données
    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Utilisateur non trouvé.' 
      });
    }
    
    // 5. Vérifier si l'utilisateur est un administrateur
    if (user.role !== 'admin') {
      return res.status(403).json({ 
        success: false, 
        message: 'Accès refusé. Droits administrateur requis.' 
      });
    }
    
    // 6. Ajouter les informations utilisateur à la requête
    req.userId = decoded.userId;
    req.userEmail = decoded.email;
    req.userRole = user.role;
    
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        success: false, 
        message: 'Token invalide.' 
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        success: false, 
        message: 'Token expiré. Veuillez vous reconnecter.' 
      });
    }
    
    console.error('Erreur dans adminAuthMiddleware:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Erreur d\'authentification administrateur.' 
    });
  }
};

module.exports = adminAuthMiddleware;