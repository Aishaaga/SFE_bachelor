// Simple test to check Allium roseum translations
const ApprovedTranslation = require('./models/ApprovedTranslation');

async function testAllium() {
  try {
    console.log('🔍 Testing Allium roseum translations...');
    
    // Find all translations for Allium roseum
    const translations = await ApprovedTranslation.find({ 
      scientificName: 'Allium roseum',
      status: 'active'
    }).sort({ approvedAt: -1 });
    
    console.log(`Found ${translations.length} translations:`);
    translations.forEach((translation, index) => {
      console.log(`  ${index + 1}. Darija: "${translation.darijaTranslation}"`);
      console.log(`     Tamazight: "${translation.tamazightTranslation}"`);
      console.log(`     Contributor: ${translation.contributorName}`);
      console.log(`     Approved: ${translation.approvedAt}`);
      console.log('');
    });
    
    // Test the getAllForPlant method
    console.log('📋 Testing getAllForPlant method:');
    const allTranslations = await ApprovedTranslation.getAllForPlant('Allium roseum');
    console.log(`getAllForPlant returned ${allTranslations.length} translations`);
    
    // Test the getForPlant method
    console.log('📋 Testing getForPlant method:');
    const singleTranslation = await ApprovedTranslation.getForPlant('Allium roseum');
    if (singleTranslation) {
      console.log(`getForPlant returned: Darija="${singleTranslation.darijaTranslation}", Tamazight="${singleTranslation.tamazightTranslation}"`);
    } else {
      console.log('getForPlant returned null');
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    process.exit();
  }
}

testAllium();
