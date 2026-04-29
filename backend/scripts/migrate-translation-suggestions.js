const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const TranslationSuggestion = require('../models/TranslationSuggestion');
const FeedPost = require('../models/FeedPost');
const User = require('../models/User');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('MongoDB connecté pour migration'))
  .catch(err => console.error('Erreur MongoDB:', err));

async function migrateTranslationSuggestions() {
  try {
    console.log('🔄 Début de la migration des suggestions de traduction...');

    // Get all translation suggestions
    const suggestions = await TranslationSuggestion.find({});
    console.log(`📊 ${suggestions.length} suggestions de traduction trouvées`);

    let migratedCount = 0;
    let errorCount = 0;

    for (const suggestion of suggestions) {
      try {
        // Find user by email to get userId
        const user = await User.findOne({ email: suggestion.contributorEmail });
        
        // Create feed post for translation suggestion
        const feedPost = new FeedPost({
          type: 'translation_suggestion',
          userId: user ? user._id : null,
          isAnonymous: false, // Translation suggestions are never anonymous
          
          // Plant information - generate a placeholder ID for translation suggestions
          plantId: `translation_${suggestion._id}`,
          plantName: suggestion.scientificName,
          scientificName: suggestion.scientificName,
          
          // Translation suggestion specific fields (note: field names in FeedPost model)
          suggestedDarija: suggestion.darijaProposal,
          suggestedTamazight: suggestion.tamazightProposal,
          upvotes: 0, // Start with 0 upvotes
          downvotes: 0, // Start with 0 downvotes
          
          // Location (from contributor region if available)
          location: {
            level: suggestion.contributorRegion ? 'city' : 'country',
            country: 'Morocco',
            city: suggestion.contributorRegion || undefined
          },
          
          // Status mapping
          status: suggestion.status === 'approved' ? 'active' : 
                  suggestion.status === 'rejected' ? 'hidden' : 
                  'flagged', // pending/needs_review -> flagged for review
          
          // Metadata
          likes: 0, // Start with 0 likes
          commentCount: 0, // Start with 0 comments
          
          // Keep original timestamps
          createdAt: suggestion.submittedAt,
          updatedAt: suggestion.reviewedAt || suggestion.submittedAt
        });

        await feedPost.save();
        migratedCount++;
        
        console.log(`✅ Migration réussie: ${suggestion.scientificName} -> ${suggestion.darijaProposal || suggestion.tamazightProposal}`);

      } catch (error) {
        console.error(`❌ Erreur lors de la migration de ${suggestion._id}:`, error.message);
        errorCount++;
      }
    }

    console.log(`\n📈 Migration terminée:`);
    console.log(`   ✅ Réussies: ${migratedCount}`);
    console.log(`   ❌ Erreurs: ${errorCount}`);
    console.log(`   📊 Total: ${suggestions.length}`);

    // Delete the old collection
    console.log('\n🗑️  Suppression de la collection "translationsuggestions"...');
    await TranslationSuggestion.deleteMany({});
    console.log('✅ Collection "translationsuggestions" supprimée');

  } catch (error) {
    console.error('❌ Erreur lors de la migration:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Déconnexion MongoDB');
  }
}

// Run migration
migrateTranslationSuggestions();
