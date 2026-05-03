# Translation Fallback System

## Overview

This system implements a hierarchical translation lookup that prioritizes static translations while falling back to database-approved user translations when needed.

## How It Works

### Step 1: Check STATIC FILE first
- The app first looks in `lib/data/plant_translations.dart`
- This contains manually curated, high-quality translations
- If found, the translation is returned immediately

### Step 2: Check DATABASE (approved translations)  
- If no static translation exists, the app queries the database
- Fetches from `/api/approved-translations/plant/:scientificName`
- Returns user-contributed translations that were approved by admins
- Results are cached to avoid repeated API calls

### Step 3: Fallback to simple name extraction
- If no translation is found in either source
- Returns the first word of the scientific name (e.g., "Rosa" from "Rosa rubiginosa")

## API Methods

### Frontend (PlantTranslations class)

#### Async Methods (Recommended)
```dart
// Uses full fallback system: Static → Database → Simple name
final darijaName = await PlantTranslations.getDarijaName('Rosa rubiginosa');
final tamazightName = await PlantTranslations.getTamazightName('Rosa rubiginosa');

// Check if any translation exists (static or database)
final hasTranslation = await PlantTranslations.hasTranslation('Rosa rubiginosa');
```

#### Sync Methods (Static Only)
```dart
// Uses only static file - no database access
final darijaName = PlantTranslations.getDarijaNameSync('Rosa rubiginosa');
final tamazightName = PlantTranslations.getTamazightNameSync('Rosa rubiginosa');
```

#### Plant Model Methods
```dart
final plant = Plant(...);

// Async methods (full fallback)
final darijaName = await plant.getDarijaNameAsync();
final tamazightName = await plant.getTamazightNameAsync();

// Sync getters (static only)
final darijaName = plant.darijaName;
final tamazightName = plant.tamazightName;
```

### Backend API Endpoint

```
GET /api/approved-translations/plant/:scientificName
Authorization: Bearer <token>

Response:
{
  "success": true,
  "translation": {
    "scientificName": "Rosa rubiginosa",
    "plantName": "Wild Rose",
    "darijaTranslation": "ورد",
    "tamazightTranslation": "ⵉⵡⵔⵉ",
    "contributorName": "User Name",
    "contributorEmail": "user@example.com",
    "approvedBy": { "name": "Admin", "email": "admin@example.com" },
    "approvedAt": "2024-01-01T00:00:00.000Z",
    "status": "active"
  }
}
```

## Caching

- Database results are cached in `_databaseCache` to avoid repeated API calls
- Cache can be cleared using:
  - `PlantTranslations.clearDatabaseCache()` - Clear all cache
  - `PlantTranslations.clearDatabaseCacheEntry('Scientific Name')` - Clear specific entry

## Usage Guidelines

### When to Use Async vs Sync

**Use Async Methods:**
- When you need the most complete translation data
- In screens where users might benefit from community translations
- When displaying detailed plant information

**Use Sync Methods:**
- In UI that needs immediate response without loading states
- In performance-critical code where database access would be too slow
- For backward compatibility with existing code

### Admin Workflow

1. **User submits translation** → Goes to FeedPost as `translation_suggestion`
2. **Community votes** → Votes tracked in TranslationVote
3. **Admin reviews** → Can approve/reject via admin dashboard
4. **Admin approves** → Creates ApprovedTranslation record
5. **Translation becomes available** → Appears in database fallback queries

## Testing

Run the test script to verify the system:
```dart
import 'lib/test_translation_fallback.dart';
void main() => main(); // This will run all tests
```

## Benefits

1. **Performance**: Static file provides instant translations for common plants
2. **Extensibility**: Database allows community contributions without code changes
3. **Reliability**: Multiple fallback options ensure some translation is always available
4. **Quality Control**: Admin approval process maintains translation quality
5. **Scalability**: System can grow with community contributions

## Migration Notes

- Existing synchronous code continues to work (uses static file only)
- New async code gets the benefit of database fallback
- UI components that need immediate response should use sync methods
- Detailed views should use async methods for complete coverage
