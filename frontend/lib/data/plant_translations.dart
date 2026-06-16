import '../services/api_service.dart';

class PlantTranslations {
  static final ApiService _apiService = ApiService();
  static final Map<String, List<Map<String, dynamic>>> _databaseCache = {};

  static final Map<String, Map<String, dynamic>> _translations = {
    'Rosa rubiginosa': {
      'translations': {
        'darija': {
          'value': 'ورد',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵉⵡⵔⵉ',
          'source': 'approximate_common_usage',
          'confidence': 'medium',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Strelitzia nicolai': {
      'translations': {
        'darija': {
          'value': 'زهرة الطائر',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⵡⵔⵉⵔⵜ ⵏ ⵓⴼⵔⵓⵅ',
          'source': 'descriptive_translation',
          'confidence': 'low',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Dracaena trifasciata': {
      'translations': {
        'darija': {
          'value': 'لسان الحية',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵉⵍⵙ ⵏ ⵓⵣⵔⵎ',
          'source': 'descriptive_translation',
          'confidence': 'low',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Helianthus annuus': {
      'translations': {
        'darija': {
          'value': 'عباد الشمس',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⵎⴰⵔⵜ ⵏ ⵉⵊⵊⵉ',
          'source': 'approximate_descriptive',
          'confidence': 'medium',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Ocimum basilicum': {
      'translations': {
        'darija': {
          'value': 'الحبق',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⴰⵎⴰⵏⵓⵙ',
          'source': 'possible_IRCAM_match',
          'confidence': 'medium',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Mentha': {
      'translations': {
        'darija': {
          'value': 'النعناع',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⵉⵎⵏⵄⴰ',
          'source': 'native_speaker',
          'confidence': 'high',
          'dialect': 'Tachelhit'
        }
      },
      'metadata': {'region': 'Souss', 'notes': ''}
    },
    'Quercus robur': {
      'translations': {
        'darija': {
          'value': 'البلوط',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⴱⴰⴳⴳⵓⵔⵜ',
          'source': 'approximate_lexical',
          'confidence': 'medium',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Pinus': {
      'translations': {
        'darija': {
          'value': 'الصنوبر',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⴷⴷⴰⴳⵜ',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Jasminum': {
      'translations': {
        'darija': {
          'value': 'الياسمين',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵉⵙⵎⵉⵏ',
          'source': 'borrowed_term',
          'confidence': 'medium',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Lavandula': {
      'translations': {
        'darija': {
          'value': 'الخزامى',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⵎⴰⵣⵉⵔⵜ',
          'source': 'approximate_regional',
          'confidence': 'low',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Argania spinosa': {
      'translations': {
        'darija': {
          'value': 'أركان',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⴰⵔⴳⴰⵏ',
          'source': 'IRCAM_verified',
          'confidence': 'high',
          'dialect': 'Tachelhit'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': 'iconic Moroccan species'}
    },
    'Olea europaea': {
      'translations': {
        'darija': {
          'value': 'الزيتون',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⵣⵎⵎⵓⵔⵜ',
          'source': 'IRCAM_verified',
          'confidence': 'high',
          'dialect': 'standard'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Punica granatum': {
      'translations': {
        'darija': {
          'value': 'الرمان',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⵔⵎⴰⵏⵜ',
          'source': 'common_amazigh_usage',
          'confidence': 'high',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Ficus carica': {
      'translations': {
        'darija': {
          'value': 'الكرموس',
          'source': 'common_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⵣⴰⵔⵜ  tazart ',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': 'unknown'
        }
      },
      'metadata': {'region': 'Morocco', 'notes': ''}
    },
    'Juniperus oxycedrus': {
      'translations': {
        'darija': {'value': '', 'source': 'unknown', 'confidence': 'low'},
        'tamazight': {
          'value': 'ⵜⵉⵔⵇⵉ/ⵜⵉⵔⵇⵉⵜ',
          'source': 'native_speaker',
          'confidence': 'high',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Tetraclinis articulata': {
      'translations': {
        'darija': {'value': '', 'source': 'unknown', 'confidence': 'low'},
        'tamazight': {
          'value': 'ⵉⵎⵉⵊⵊⴷ/ⵜⴰⵣⵓⵜ/ⵜⴰⴳⴰⵔⴳⴰⵔⵜ',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Clematis cirrhosa': {
      'translations': {
        'darija': {'value': '', 'source': 'unknown', 'confidence': 'low'},
        'tamazight': {
          'value': 'ⵉⴳⵓⴷⵉ',
          'source': 'regional_usage',
          'confidence': 'low',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Juniperus thurifera': {
      'translations': {
        'darija': {'value': '', 'source': 'unknown', 'confidence': 'low'},
        'tamazight': {
          'value': 'ⴰⴷⵔⵓⵎⴰⵏ/ⴰⵡⴰⵍ/ⵜⴰⵡⵍⵜ',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Bupleurum spinosum': {
      'translations': {
        'darija': {'value': '', 'source': 'unknown', 'confidence': 'low'},
        'tamazight': {
          'value': 'ⴰⴷⵓⴼⵙⴰⵙ',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Leucaena leucocephala': {
      'translations': {
        'darija': {'value': '', 'source': 'unknown', 'confidence': 'low'},
        'tamazight': {
          'value': 'ⵜⵉⴽⵉⴷⴰ/tikida',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'phonus arborescens': {
      'translations': {
        'darija': {'value': '', 'source': 'unknown', 'confidence': 'low'},
        'tamazight': {
          'value': 'ⴰⵛⴼⴼⴰⵕ/Asffar',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Senecio vulgaris': {
      'translations': {
        'darija': {
          'value': ' زهرة الشيخ ',
          'source': 'regional_usage',
          'confidence': 'low'
        },
        'tamazight': {
          'value': 'ⵜⴰⵍⵍⵓⵛⵜ ⵏ ⵓⵊⴰⵔⴼⵉ/ⵜⵉⴷⵎⴰⵎⴰⵢ \ntalluct n ujarfi/tidmamay',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Saponaria ocymoides': {
      'translations': {
        'darija': {
          'value': 'الصابونية/عرق الحلاوة',
          'source': '',
          'confidence': 'very low'
        },
        'tamazight': {
          'value': 'ⵜⴰⵖⵉⵖⴰⵛⵜ ⵜⴰⵣⵡⴰⵡⴰⵖⵜ \ntaɣiɣact tazwawaɣt',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        } //https://imghayn.blogspot.com/2023/01/iris.html
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Iris xiphium': {
      'translations': {
        'darija': {'value': '', 'source': '', 'confidence': 'very low'},
        'tamazight': {
          'value': '',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': 'Souss', 'notes': 'needs darija validation'}
    },
    'Iris paradoxa': {
      'translations': {
        'darija': {
          'value': 'السوسن البري',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⴰⵙⵍⵉⵏ \nAslin',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Iris unguicularis': {
      'translations': {
        'darija': {
          'value': 'سوسن جزائري',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⴰⵊⴻⵊⵊⵉⴳ ⴳⴻⵔⴼⵉ \nAjejjig gerfi',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Iris pseudacorus': {
      'translations': {
        'darija': {
          'value': 'سوسن أصفر',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⴰⵣⴻⵏⴼⴰⵕ \nAzefar',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Iris × germanica': {
      'translations': {
        'darija': {
          'value': 'عود العنبر \nسيف الديب',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⵜⴰⴼⵔⵓⵜ ⵉⵎⴻⵇⵇⵓⵔⵏ \nTafurt imeqqurn',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    //list
    ///****************************** */

    'Salvia rosmarinus': {
      'translations': {
        'darija': {
          'value': 'اليازير/آزير',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⴰⵣⵉⵔ Azir \nⵜⴰⵎⴻⵣⵣⵉⵔⴰ Tamzzira',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': 'Souss'
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Thymus vulgaris': {
      'translations': {
        'darija': {
          'value': 'الزعتر',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⴰⵣⵓⴽⵏⵏⵉ Azuknni',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': 'Souss'
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Lavandula dentata': {
      'translations': {
        'darija': {
          'value': 'الخزامى',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⵢⵎⵔⵣⴰ taymrza \nⴱⵓⵜⵓⵖⵎⴰⵙ butuɣmas',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Salvia officinalis': {
      'translations': {
        'darija': {
          'value': 'السالمية',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value':
              'ⵜⴰⵢⵎⵔⵣⴰ butanzarin \nⴱⵓ ⵡⴰⵏⵣⴰⵔⵏ bu wanzarn \nⵜⴰⵣⵣⵓⵔⵜ tazzurt ',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Artemisia herba-alba': {
      'translations': {
        'darija': {
          'value': 'الشيح',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵉⵣⵔⵉ izri \nⵉⵣⵔⴻⵢ izrey',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Foeniculum vulgare': {
      'translations': {
        'darija': {
          'value': 'البسباس',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⴰⴱⵙⴱⴰⵙ absbas \nⴰⵎⵙⵙⴰ amsa',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Cedrus atlantica': {
      'translations': {
        'darija': {
          'value': 'أرز',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵉⴷⴳⴻⵍ ⵏ ⵡⴰⵜⵍⴰⵙ idgel n watlas',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Quercus coccifera': {
      'translations': {
        'darija': {'value': 'البلوط القرمزي', 'source': '', 'confidence': ''},
        'tamazight': {
          'value': 'ⵜⴰⵙⴰⴼⵜ ⵢⵉⵣⵎ tasaft yizem',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Quercus suber': {
      'translations': {
        'darija': {'value': 'بلوط الفلين', 'source': '', 'confidence': ''},
        'tamazight': {
          'value': 'ⴰⴼⴻⵔⵏⴰⵏ afernan \nⵜⴰⵙⴰⴼⵜ ⵎⵎ ⴰⴼⵔⵛⵉ tasaft mm afrchi',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Quercus ilex': {
      'translations': {
        'darija': {
          'value': 'البلوط',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⴰⵙⴰⴼⵜ tasaft \nⵜⴰⴽⵔⵔⵓⵛⵜ takerrucht',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Nerium oleander': {
      'translations': {
        'darija': {'value': '', 'source': '', 'confidence': ''},
        'tamazight': {
          'value': 'ⴰⵍⵉⵍⵉ alili',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Laurus nobilis': {
      'translations': {
        'darija': {
          'value': 'نبات الغار',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⵜⴰⵙⵙⴻⵍⵜ tasselt \nⵉⴳⴻⵔⵙⵍ igersel \nⵜⴰⵔⵙⴻⵍⵜ tarselt',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Ziziphus lotus': {
      'translations': {
        'darija': {
          'value': 'السدر',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⴰⵣⴻⴳⴳⵯⴰⵔ  azeggarr \nⵜⴰⵣⴻⴳⴳⵯⴰⵔⵜ  tazeggart',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Pistacia atlantica': {
      'translations': {
        'darija': {
          'value': 'ⵖⵓⵟⵎⴰ  buṭma',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⵉⴳⴳ ⴰⵏⴰⵟⵍⴰⵙ  igg anaṭlas \nⵉⵇⵇ ⴰⵏⴰⵟⵍⴰⵙ  iqq anaṭlas',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Opuntia ficus-indica': {
      'translations': {
        'darija': {
          'value': 'هندية / كرموس',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⴰⴽⵏⴰⵔⵉ  aknari \nⵜⴰⴽⵏⴰⵔⵉⵜ  taknarit',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Macrochloa tenacissima': {
      'translations': {
        'darija': {
          'value': '',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': '',
          'source': 'regional_usage',
          'confidence': 'medium',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Euphorbia resinifera': {
      'translations': {
        'darija': {
          'value': 'دبغ',
          'source': 'regional_usage',
          'confidence': 'medium'
        },
        'tamazight': {
          'value': 'ⵜⵉⴽⵉⵡⵜ',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    },
    'Allium sativum': {
      'translations': {
        'darija': {
          'value': 'الثومة ',
          'source': 'regional_usage',
          'confidence': 'high'
        },
        'tamazight': {
          'value': 'ⵜⵉⵙⴽⴻⵔⵜ  tiskert',
          'source': 'regional_usage',
          'confidence': 'high',
          'dialect': ''
        }
      },
      'metadata': {'region': '', 'notes': ''}
    }
  };

//ⵜⴰⵖⵉⵖⴰⵛⵜ ⵜⴰⵣⵡⴰⵡⴰⵖⵜ
  // =========================
  // UPDATED METHODS
  // =========================

  static Future<String> getDarijaName(String scientificName) async {
    // Step 1: Check STATIC FILE first
    final match = _translations[scientificName];
    final staticValue = match?['translations']?['darija']?['value'];

    if (staticValue != null && staticValue.isNotEmpty) {
      return staticValue;
    }

    // Step 2: Check DATABASE (approved translations)
    final dbTranslations = await _getFromDatabase(scientificName);
    if (dbTranslations.isNotEmpty) {
      final dbValue = dbTranslations.first['darijaTranslation'];
      if (dbValue != null && dbValue.isNotEmpty) {
        return dbValue;
      }
    }

    // Step 3: Fallback to simple name extraction
    return _extractSimpleName(scientificName);
  }

  static Future<String> getTamazightName(String scientificName) async {
    // Step 1: Check STATIC FILE first
    final match = _translations[scientificName];
    final staticValue = match?['translations']?['tamazight']?['value'];

    if (staticValue != null && staticValue.isNotEmpty) {
      return staticValue;
    }

    // Step 2: Check DATABASE (approved translations)
    final dbTranslations = await _getFromDatabase(scientificName);
    if (dbTranslations.isNotEmpty) {
      final dbValue = dbTranslations.first['tamazightTranslation'];
      if (dbValue != null && dbValue.isNotEmpty) {
        return dbValue;
      }
    }

    // Step 3: Fallback to Darija name
    return await getDarijaName(scientificName);
  }

  // NEW: Get ALL approved translations for a plant
  static Future<List<Map<String, dynamic>>> getAllApprovedTranslations(
      String scientificName) async {
    return await _getFromDatabase(scientificName);
  }

  // NEW: Get ALL Darija translations for a plant
  static Future<List<String>> getAllDarijaNames(String scientificName) async {
    final dbTranslations = await _getFromDatabase(scientificName);
    return dbTranslations
        .map((translation) => translation['darijaTranslation'] as String?)
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toList();
  }

  // NEW: Get ALL Tamazight translations for a plant
  static Future<List<String>> getAllTamazightNames(
      String scientificName) async {
    final dbTranslations = await _getFromDatabase(scientificName);
    return dbTranslations
        .map((translation) => translation['tamazightTranslation'] as String?)
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toList();
  }

  // Helper method to fetch ALL translations from database with caching
  static Future<List<Map<String, dynamic>>> _getFromDatabase(
      String scientificName) async {
    // Check cache first
    if (_databaseCache.containsKey(scientificName)) {
      return _databaseCache[scientificName]!;
    }

    // Fetch from API
    final translations =
        await _apiService.getApprovedTranslations(scientificName);

    // Cache the result (even if empty to avoid repeated API calls)
    _databaseCache[scientificName] = translations;

    return translations;
  }

  static Map<String, dynamic>? getFullData(String scientificName) {
    return _translations[scientificName];
  }

  static String _extractSimpleName(String scientificName) {
    final parts = scientificName.split(' ');
    return parts.isNotEmpty ? parts[0] : scientificName;
  }

  // Synchronous versions for backward compatibility
  // These only check static file (no database access)
  static String getDarijaNameSync(String scientificName) {
    final match = _translations[scientificName];
    return match?['translations']?['darija']?['value'] ??
        _extractSimpleName(scientificName);
  }

  static String getTamazightNameSync(String scientificName) {
    final match = _translations[scientificName];
    return match?['translations']?['tamazight']?['value'] ??
        getDarijaNameSync(scientificName);
  }

  // Cache management methods
  static void clearDatabaseCache() {
    _databaseCache.clear();
  }

  static void clearDatabaseCacheEntry(String scientificName) {
    _databaseCache.remove(scientificName);
  }

  // Force refresh translations from database (bypass cache)
  static Future<List<Map<String, dynamic>>> refreshTranslations(
      String scientificName) async {
    // Clear cache for this specific plant
    clearDatabaseCacheEntry(scientificName);

    // Fetch fresh data from API
    final translations =
        await _apiService.getApprovedTranslations(scientificName);

    // Cache the fresh result
    _databaseCache[scientificName] = translations;

    return translations;
  }

  // Method to check if plant has any translation (static or database)
  static Future<bool> hasTranslation(String scientificName) async {
    // Check static file first
    if (_translations.containsKey(scientificName)) {
      final match = _translations[scientificName];
      final darijaValue = match?['translations']?['darija']?['value'];
      final tamazightValue = match?['translations']?['tamazight']?['value'];

      if ((darijaValue != null && darijaValue.isNotEmpty) ||
          (tamazightValue != null && tamazightValue.isNotEmpty)) {
        return true;
      }
    }

    // Check database
    final dbTranslations = await _getFromDatabase(scientificName);
    if (dbTranslations.isNotEmpty) {
      return dbTranslations.any((translation) {
        final darijaValue = translation['darijaTranslation'] as String?;
        final tamazightValue = translation['tamazightTranslation'] as String?;
        return (darijaValue != null && darijaValue.isNotEmpty) ||
            (tamazightValue != null && tamazightValue.isNotEmpty);
      });
    }

    return false;
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
      'translations': {
        'darija': {
          'value': darija,
          'source': darijaSource,
          'confidence': darijaConfidence
        },
        'tamazight': {
          'value': tamazight,
          'source': tamazightSource,
          'confidence': tamazightConfidence
        }
      },
      'metadata': {'region': 'Morocco', 'notes': 'user contributed'}
    };
  }

  //counting translated palnts:
  static int getPlantCount() {
    return _translations.length;
  }

  static int getValidPlantCount() {
    return _translations.values.where((plant) {
      final darijaValue = plant['translations']?['darija']?['value'];
      final tamazightValue = plant['translations']?['tamazight']?['value'];
      return darijaValue != null &&
          darijaValue.isNotEmpty &&
          tamazightValue != null &&
          tamazightValue.isNotEmpty;
    }).length;
  }

  static int countHighConfidenceTamazight() {
    return _translations.values.where((plant) {
      return plant['translations']?['tamazight']?['confidence'] == 'high';
    }).length;
  }

  static int countWithAmazighTranslation() {
    return _translations.values.where((plant) {
      final tamazightValue = plant['translations']?['tamazight']?['value'];
      return tamazightValue != null && tamazightValue.isNotEmpty;
    }).length;
  }

  static int countWithDarijaTranslation() {
    return _translations.values.where((plant) {
      final darijaValue = plant['translations']?['darija']?['value'];
      return darijaValue != null && darijaValue.isNotEmpty;
    }).length;
  }

  static int countWithBothTranslations() {
    return _translations.values.where((plant) {
      final darijaValue = plant['translations']?['darija']?['value'];
      final tamazightValue = plant['translations']?['tamazight']?['value'];
      return darijaValue != null &&
          darijaValue.isNotEmpty &&
          tamazightValue != null &&
          tamazightValue.isNotEmpty;
    }).length;
  }

  static void printAllPlants() {
    _translations.forEach((key, value) {
      print(key);
    });
  }
}

//references:
class References {
  static const refs = {
    'GeoEcoTrop2022': {
      'title': 'Geo-Eco-Trop., 2022, 46(3): 403–412',
      'journal': 'Geo-Eco-Trop',
      'type': 'article',
      'url': 'https://www.geoecotrop.be/uploads/publications/pub_463_04.pdf'
    }
  };
}
