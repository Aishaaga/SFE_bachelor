import 'data/plant_translations.dart';
import 'services/api_service.dart';

/// Test script to verify the translation fallback system
/// 
/// This script tests:
/// 1. Static file translations (existing plants)
/// 2. Database fallback (for plants not in static file)
/// 3. Fallback to simple name extraction
/// 
/// Usage: Run this in a Dart environment with proper authentication
void main() async {
  print('🌱 Testing Translation Fallback System\n');
  
  // Test 1: Plant that exists in static file
  print('📋 Test 1: Plant in static file (Rosa rubiginosa)');
  await testTranslation('Rosa rubiginosa');
  
  // Test 2: Plant that doesn't exist in static file
  print('\n📋 Test 2: Plant NOT in static file (Test Plant)');
  await testTranslation('Test Plant Not In File');
  
  // Test 3: Another plant from static file
  print('\n📋 Test 3: Another plant from static file (Argania spinosa)');
  await testTranslation('Argania spinosa');
  
  print('\n✅ Translation fallback system test completed!');
}

Future<void> testTranslation(String scientificName) async {
  print('  🔍 Testing: $scientificName');
  
  // Test synchronous (static file only)
  final darijaSync = PlantTranslations.getDarijaNameSync(scientificName);
  final tamazightSync = PlantTranslations.getTamazightNameSync(scientificName);
  print('  📖 Static File Only:');
  print('    Darija: "$darijaSync"');
  print('    Tamazight: "$tamazightSync"');
  
  // Test asynchronous (static file + database fallback)
  final darijaAsync = await PlantTranslations.getDarijaName(scientificName);
  final tamazightAsync = await PlantTranslations.getTamazightName(scientificName);
  print('  🌐 Static + Database Fallback:');
  print('    Darija: "$darijaAsync"');
  print('    Tamazight: "$tamazightAsync"');
  
  // Check if translation exists
  final hasTranslation = await PlantTranslations.hasTranslation(scientificName);
  print('  ✅ Has Translation: $hasTranslation');
  
  // Show if fallback was used
  final usedFallback = darijaAsync != darijaSync || tamazightAsync != tamazightSync;
  if (usedFallback) {
    print('  🔄 Database fallback was used!');
  } else {
    print('  📚 Static file was sufficient');
  }
}

/// Test the API service directly (requires authentication)
Future<void> testApiService() async {
  print('\n🔌 Testing API Service directly...');
  
  final apiService = ApiService();
  
  // Test with a plant that might have approved translations
  final result = await apiService.getApprovedTranslation('Rosa rubiginosa');
  
  if (result != null) {
    print('  ✅ Found approved translation:');
    print('    Darija: ${result['darijaTranslation']}');
    print('    Tamazight: ${result['tamazightTranslation']}');
    print('    Contributed by: ${result['contributorName']}');
  } else {
    print('  ❌ No approved translation found');
  }
}
