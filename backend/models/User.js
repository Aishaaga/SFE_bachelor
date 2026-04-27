const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  role: {
    type: String,
    default: 'user'
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
    role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  }
});

// Version avec async/await - PAS de paramètre 'next'
userSchema.pre('save', async function() {
  console.log('🔐 pre save - hachage');
  
  if (!this.isModified('password')) {
    console.log('Mot de passe non modifié');
    return;
  }
  
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  console.log('Mot de passe haché');
});

// Méthode pour comparer les mots de passe
userSchema.methods.comparePassword = async function(candidatePassword) {
  console.log(' Comparaison...');
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);