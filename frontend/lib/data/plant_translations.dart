class PlantTranslations {
  static final Map<String, Map<String, String>> _translations = {
    // Scientific name -> {darija, tamazight}
    'Rosa rubiginosa': {
      'darija': 'ورد',
      'tamazight': 'ⵉⵡⵔⵉ',
    },
    'Strelitzia nicolai': {
      'darija': 'زهرة الطائر',
      'tamazight': 'ⵜⴰⵡⵔⵉⵔⵜ ⵏ ⵓⴼⵔⵓⵅ',
    },
    'Dracaena trifasciata': {
      'darija': 'لسان الحية',
      'tamazight': 'ⵉⵍⵙ ⵏ ⵓⵣⵔⵎ',
    },
    'Helianthus annuus': {
      'darija': 'عباد الشمس',
      'tamazight': 'ⵜⴰⵎⴰⵔⵜ ⵏ ⵉⵊⵊⵉ',
    },
    'Ocimum basilicum': {
      'darija': 'الحبق',
      'tamazight': 'ⴰⵎⴰⵏⵓⵙ',
    },
    'Mentha': {
      'darija': 'النعناع',
      'tamazight': 'ⵜⵉⵎⵏⵄⴰ',
    },
    'Quercus robur': {
      'darija': 'البلوط',
      'tamazight': 'ⵜⴰⴱⴰⴳⴳⵓⵔⵜ',
    },
    'Pinus': {
      'darija': 'الصنوبر',
      'tamazight': 'ⵜⴰⴷⴷⴰⴳⵜ',
    },
    'Jasminum': {
      'darija': 'الياسمين',
      'tamazight': 'ⵉⵙⵎⵉⵏ',
    },
    'Lavandula': {
      'darija': 'الخزامى',
      'tamazight': 'ⵜⴰⵎⴰⵣⵉⵔⵜ',
    },
  };

  static String getDarijaName(String scientificName) {
    final match = _translations[scientificName];
    if (match != null && match.containsKey('darija')) {
      return match['darija']!;
    }

    // Fallback: extract from scientific name
    return _extractSimpleName(scientificName);
  }

  static String getTamazightName(String scientificName) {
    final match = _translations[scientificName];
    if (match != null && match.containsKey('tamazight')) {
      return match['tamazight']!;
    }

    // Fallback: use Darija or scientific name
    return getDarijaName(scientificName);
  }

  static String _extractSimpleName(String scientificName) {
    // "Rosa rubiginosa" -> "Rosa"
    final parts = scientificName.split(' ');
    if (parts.isNotEmpty) {
      return parts[0];
    }
    return scientificName;
  }

  // Add new translation (user contributed)
  static void addTranslation(
      String scientificName, String darija, String tamazight) {
    _translations[scientificName] = {
      'darija': darija,
      'tamazight': tamazight,
    };
  }

  // Check if translation exists
  static bool hasTranslation(String scientificName) {
    return _translations.containsKey(scientificName);
  }
}
