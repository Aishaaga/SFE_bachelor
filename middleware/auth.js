const jwt = require('jsonwebtoken');

const authMiddleware = async (req, res, next) => {
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
    
    // 4. Ajouter l'ID utilisateur à la requête
    req.userId = decoded.userId;
    req.userEmail = decoded.email;
    
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
    
    res.status(500).json({ 
      success: false, 
      message: 'Erreur d\'authentification.' 
    });
  }
};

module.exports = authMiddleware;