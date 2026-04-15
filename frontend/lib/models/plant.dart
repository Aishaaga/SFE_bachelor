import '../data/plant_translations.dart';

class Plant {
  final String id;
  final String name;
  final String scientificName;
  final String family;
  final String? localName;
  final double confidence;

  String get darijaName => PlantTranslations.getDarijaName(scientificName);
  String get tamazightName =>
      PlantTranslations.getTamazightName(scientificName);

  Plant({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.family,
    this.localName,
    required this.confidence,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Plante inconnue',
      scientificName:
          json['scientificName'] ?? json['name'] ?? 'Nom scientifique inconnu',
      localName: json['localName'] as String?,
      family: json['family'] ?? 'Famille inconnue',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }

  // Add this method for easier conversion
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scientificName': scientificName,
      'confidence': confidence,
      'family': family,
      'id': id,
    };
  }

  // Helper method for display
  String get displayName {
    if (scientificName.isNotEmpty &&
        scientificName != 'Nom scientifique inconnu') {
      return scientificName;
    }
    return name;
  }

  // Helper method for confidence percentage
  int get confidencePercentage => (confidence * 100).toInt();

  // Check if identification is reliable
  bool get isReliable => confidence >= 0.5;
}
