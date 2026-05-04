// Check what's actually in the database for Allium roseum
const ApprovedTranslation = require('./models/ApprovedTranslation');

async function checkAllium() {
  try {
    console.log('🔍 Checking Allium roseum in database...\n');
    
    // Find ALL documents (not just active ones) for Allium roseum
    const allTranslations = await ApprovedTranslation.find({ 
      scientificName: 'Allium roseum' 
    }).sort({ approvedAt: -1 });
    
    console.log(`Found ${allTranslations.length} total documents for Allium roseum:`);
    allTranslations.forEach((doc, index) => {
      console.log(`\n${index + 1}. Document ID: ${doc._id}`);
      console.log(`   Scientific Name: "${doc.scientificName}"`);
      console.log(`   Darija Translation: "${doc.darijaTranslation}"`);
      console.log(`   Tamazight Translation: "${doc.tamazightTranslation}"`);
      console.log(`   Status: "${doc.status}"`);
      console.log(`   Contributor: ${doc.contributorName} (${doc.contributorEmail})`);
      console.log(`   Approved At: ${doc.approvedAt}`);
      console.log(`   Approved By: ${doc.approvedBy?.email || 'Unknown'}`);
    });
    
    // Find only ACTIVE ones
    const activeTranslations = await ApprovedTranslation.find({ 
      scientificName: 'Allium roseum',
      status: 'active'
    }).sort({ approvedAt: -1 });
    
    console.log(`\n📊 Found ${activeTranslations.length} ACTIVE translations for Allium roseum`);
    
    // Test the getAllForPlant method
    console.log('\n🔧 Testing getAllForPlant method:');
    const methodResult = await ApprovedTranslation.getAllForPlant('Allium roseum');
    console.log(`getAllForPlant returned ${methodResult.length} translations`);
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit();
  }
}

checkAllium();
