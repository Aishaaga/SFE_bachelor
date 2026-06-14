const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 30
  },
  password: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['user', 'admin'],
    default: 'user'
  },
  name: {
    type: String,
    required: false,
    trim: true,
    default: ''
  },
  bio: {
    type: String,
    required: false,
    trim: true,
    default: ''
  },
  location: {
    type: String,
    required: false,
    trim: true,
    default: ''
  },
  profileImage: {
    type: String,
    required: false,
    default: ''
  },
  contributionsCount: {
    type: Number,
    default: 0
  },
  identificationsCount: {
    type: Number,
    default: 0
  },
  translationSuggestionsCount: {
    type: Number,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// ✅ UN SEUL pre('save') - version corrigée
userSchema.pre('save', async function() {
  console.log('🔐 pre save - hachage');

  if (!this.isModified('password')) {
    console.log('Mot de passe non modifié');
    return;
  }

  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    console.log('✅ Mot de passe haché');
  } catch (error) {
    throw error;
  }
});

// ✅ Méthode comparePassword
userSchema.methods.comparePassword = async function(password) {
  console.log('🔍 Comparaison bcrypt...');
  const isValid = await bcrypt.compare(password, this.password);
  console.log('📊 Résultat comparaison:', isValid);
  return isValid;
};

module.exports = mongoose.model('User', userSchema);