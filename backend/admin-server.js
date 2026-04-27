// admin-server.js - No wildcard routes (compatible with your Express)
const express = require('express');
const path = require('path');
const app = express();
const PORT = 4000;

const adminPath = path.join(__dirname, 'admin');

// Serve all static files (HTML, CSS, JS) from admin folder
app.use(express.static(adminPath));

// Simple server - no wildcard routes needed
// express.static already handles all file requests

app.listen(PORT, () => {
  console.log(`🌿 ADMIN PANEL: http://localhost:${PORT}`);
  console.log(`   Login page: http://localhost:${PORT}/index.html`);
  console.log(`   Dashboard: http://localhost:${PORT}/dashboard.html`);
});