class PlantTranslations {
  static final Map<String, Map<String, dynamic>> _translations = {
    'Rosa rubiginosa': {
      'darija': 'ورد',
      'tamazight': 'ⵉⵡⵔⵉ',
      'sources': {
        'tamazight': 'approximate / common usage',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'medium', 'darija': 'high'}
    },
    'Strelitzia nicolai': {
      'darija': 'زهرة الطائر',
      'tamazight': 'ⵜⴰⵡⵔⵉⵔⵜ ⵏ ⵓⴼⵔⵓⵅ',
      'sources': {
        'tamazight': 'descriptive translation',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'low', 'darija': 'high'}
    },
    'Dracaena trifasciata': {
      'darija': 'لسان الحية',
      'tamazight': 'ⵉⵍⵙ ⵏ ⵓⵣⵔⵎ',
      'sources': {
        'tamazight': 'descriptive translation',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'low', 'darija': 'high'}
    },
    'Helianthus annuus': {
      'darija': 'عباد الشمس',
      'tamazight': 'ⵜⴰⵎⴰⵔⵜ ⵏ ⵉⵊⵊⵉ',
      'sources': {
        'tamazight': 'approximate / descriptive',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'medium', 'darija': 'high'}
    },
    'Ocimum basilicum': {
      'darija': 'الحبق',
      'tamazight': 'ⴰⵎⴰⵏⵓⵙ',
      'sources': {
        'tamazight': 'possible IRCAM lexical match',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'medium', 'darija': 'high'}
    },
    'Mentha': {
      'darija': 'النعناع',
      'tamazight': 'ⵜⵉⵎⵏⵄⴰ',
      'sources': {
        'tamazight': 'common usage (Souss)',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'high', 'darija': 'high'}
    },
    'Quercus robur': {
      'darija': 'البلوط',
      'tamazight': 'ⵜⴰⴱⴰⴳⴳⵓⵔⵜ',
      'sources': {
        'tamazight': 'approximate lexical match',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'medium', 'darija': 'high'}
    },
    'Pinus': {
      'darija': 'الصنوبر',
      'tamazight': 'ⵜⴰⴷⴷⴰⴳⵜ',
      'sources': {'tamazight': 'regional usage', 'darija': 'common usage'},
      'confidence': {'tamazight': 'medium', 'darija': 'high'}
    },
    'Jasminum': {
      'darija': 'الياسمين',
      'tamazight': 'ⵉⵙⵎⵉⵏ',
      'sources': {'tamazight': 'borrowed term', 'darija': 'common usage'},
      'confidence': {'tamazight': 'medium', 'darija': 'high'}
    },
    'Lavandula': {
      'darija': 'الخزامى',
      'tamazight': 'ⵜⴰⵎⴰⵣⵉⵔⵜ',
      'sources': {
        'tamazight': 'approximate / regional',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'low', 'darija': 'high'}
    },
    'Argania spinosa': {
      'darija': 'أركان',
      'tamazight': 'ⴰⵔⴳⴰⵏ',
      'sources': {
        'tamazight': 'verified (IRCAM usage)',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'high', 'darija': 'high'}
    },
    'Olea europaea': {
      'darija': 'الزيتون',
      'tamazight': 'ⵜⴰⵣⵎⵎⵓⵔⵜ',
      'sources': {
        'tamazight': 'verified (IRCAM lexicon)',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'high', 'darija': 'high'}
    },
    'Punica granatum': {
      'darija': 'الرمان',
      'tamazight': 'ⵜⴰⵔⵎⴰⵏⵜ',
      'sources': {
        'tamazight': 'common Amazigh usage',
        'darija': 'common usage'
      },
      'confidence': {'tamazight': 'high', 'darija': 'high'}
    },
    'Ficus carica': {
      'darija': 'الكرموس',
      'tamazight': 'ⵜⴰⵣⵉⵔⵜ',
      'sources': {'tamazight': 'regional usage', 'darija': 'common usage'},
      'confidence': {'tamazight': 'medium', 'darija': 'high'}
    },
  };

  // =========================
  // UPDATED METHODS
  // =========================

  static String getDarijaName(String scientificName) {
    final match = _translations[scientificName];
    return match?['darija'] ?? _extractSimpleName(scientificName);
  }

  static String getTamazightName(String scientificName) {
    final match = _translations[scientificName];
    return match?['tamazight'] ?? getDarijaName(scientificName);
  }

  static Map<String, dynamic>? getFullData(String scientificName) {
    return _translations[scientificName];
  }

  static String _extractSimpleName(String scientificName) {
    final parts = scientificName.split(' ');
    return parts.isNotEmpty ? parts[0] : scientificName;
  }

  static void addTranslation(
    String scientificName,
    String darija,
    String tamazight, {
    String darijaSource = 'user contributed',
    String tamazightSource = 'user contributed',
    String darijaConfidence = 'medium',
    String tamazightConfidence = 'medium',
  }) {
    _translations[scientificName] = {
      'darija': darija,
      'tamazight': tamazight,
      'sources': {
        'tamazight': tamazightSource,
        'darija': darijaSource,
      },
      'confidence': {
        'tamazight': tamazightConfidence,
        'darija': darijaConfidence,
      }
    };
  }

  static bool hasTranslation(String scientificName) {
    return _translations.containsKey(scientificName);
  }

  //counting translated palnts:
  static int getPlantCount() {
    return _translations.length;
  }

  static int getValidPlantCount() {
    return _translations.values.where((plant) {
      return plant['darija'] != null && plant['tamazight'] != null;
    }).length;
  }

  static int countHighConfidenceTamazight() {
    return _translations.values.where((plant) {
      return plant['confidence']?['tamazight'] == 'high';
    }).length;
  }

  static void printAllPlants() {
    _translations.forEach((key, value) {
      print(key);
    });
  }
}
