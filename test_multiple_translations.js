const mongoose = require('mongoose');
const ApprovedTranslation = require('./backend/models/ApprovedTranslation');

// Test script to verify multiple translations are working
async function testMultipleTranslations() {
  try {
    // Connect to MongoDB (adjust connection string as needed)
    await mongoose.connect('mongodb://localhost:27017/sfe-app', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('🔍 Testing multiple translations for a plant...\n');

    // Test scientific name
    const scientificName = 'Rosa rubiginosa';

    // Test the old getForPlant method (should return only one)
    console.log('📋 Testing getForPlant (old method - should return only one):');
    const singleTranslation = await ApprovedTranslation.getForPlant(scientificName);
    if (singleTranslation) {
      console.log(`  ✅ Found: Darija="${singleTranslation.darijaTranslation}", Tamazight="${singleTranslation.tamazightTranslation}"`);
    } else {
      console.log('  ❌ No translation found');
    }

    console.log('\n📋 Testing getAllForPlant (new method - should return all):');
    const allTranslations = await ApprovedTranslation.getAllForPlant(scientificName);
    console.log(`  ✅ Found ${allTranslations.length} translation(s):`);
    allTranslations.forEach((translation, index) => {
      console.log(`    ${index + 1}. Darija="${translation.darijaTranslation}", Tamazight="${translation.tamazightTranslation}"`);
      console.log(`       Contributor: ${translation.contributorName}, Approved: ${translation.approvedAt}`);
    });

    console.log('\n🎯 Summary:');
    console.log(`  - getForPlant returned: ${singleTranslation ? 1 : 0} translation`);
    console.log(`  - getAllForPlant returned: ${allTranslations.length} translations`);
    
    if (allTranslations.length > 1) {
      console.log('  ✅ SUCCESS: Multiple translations are being returned correctly!');
    } else if (allTranslations.length === 1) {
      console.log('  ⚠️  WARNING: Only one translation found. The issue might be in the data.');
    } else {
      console.log('  ❌ ERROR: No translations found for this plant.');
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
  }
}

// Run the test
testMultipleTranslations();
