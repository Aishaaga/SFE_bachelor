// Purpose: Check if the logged-in user is an admin
// Location: sfe-backend/middleware/adminAuth.js

const jwt = require('jsonwebtoken');
const User = require('../models/User');

// This middleware runs AFTER regular auth (user is already logged in)
async function adminAuth(req, res, next) {
  try {
    // Get user ID from the request (set by regular auth middleware)
    const userId = req.userId;
    
    // Find the user in database
    const user = await User.findById(userId);
    
    // If user doesn't exist
    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: 'User not found' 
      });
    }
    
    // Check if user has admin role
    if (user.role !== 'admin') {
      return res.status(403).json({ 
        success: false, 
        message: 'Access denied. Admin privileges required.' 
      });
    }
    
    // User is admin, proceed to next function
    next();
    
  } catch (error) {
    console.error('Admin auth error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server error' 
    });
  }
}

module.exports = adminAuth;