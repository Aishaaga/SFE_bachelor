import 'package:flutter/material.dart';
import '../data/plant_translations.dart';
import '../utils/constants.dart';

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> identification;

  const PlantDetailScreen({super.key, required this.identification});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  int _currentImageIndex = 0;

  List<String> _getPlantImages() {
    final List<String> images = [];

    // Check if this is a grouped plant (new format) or single identification (old format)
    if (widget.identification.containsKey('photoUrls')) {
      // New grouped format
      final List<String> photoUrls =
          List<String>.from(widget.identification['photoUrls'] ?? []);
      for (String photoUrl in photoUrls) {
        final fullUrl =
            '${Constants.apiUrl.substring(0, Constants.apiUrl.indexOf('/api'))}$photoUrl';
        images.add(fullUrl);
      }
    } else if (widget.identification['photoUrl'] != null) {
      // Old single identification format
      final mainPhoto =
          '${Constants.apiUrl.substring(0, Constants.apiUrl.indexOf('/api'))}${widget.identification['photoUrl']}';
      images.add(mainPhoto);
    }

    return images;
  }

  String _getPlantUsage(String scientificName) {
    // You could expand this with more detailed usage information
    final Map<String, String> usageInfo = {
      'Argania spinosa':
          'L\'arganier est un arbre emblématique du Maroc. Son huile est utilisée en cosmétique et en cuisine. Le bois est utilisé pour le chauffage et l\'artisanat.',
      'Olea europaea':
          'L\'olivier est cultivé pour ses fruits qui produisent l\'huile d\'olive, un pilier de la cuisine méditerranéenne. Le bois est également utilisé en ébénisterie.',
      'Punica granatum':
          'Le grenadier produit des grenades riches en antioxydants. Le jus et les graines sont consommés, l\'écorce est utilisée en médecine traditionnelle.',
      'Mentha':
          'La menthe est utilisée pour préparer le thé à la menthe, boisson traditionnelle marocaine. Elle possède également des propriétés digestives et rafraîchissantes.',
      'Salvia rosmarinus':
          'Le romarin est utilisé comme aromate en cuisine et en médecine traditionnelle pour ses propriétés antioxydantes et stimulantes.',
      'Thymus vulgaris':
          'Le thym est utilisé comme herbe aromatique et en médecine traditionnelle pour ses propriétés antiseptiques et expectorantes.',
      'Lavandula':
          'La lavande est utilisée en parfumerie, en cosmétique et en aromathérapie pour ses propriétés relaxantes.',
      'Cedrus atlantica':
          'Le cèdre de l\'Atlas est un arbre majestueux dont le bois est très prisé en construction et en ébénisterie.',
      'Quercus ilex':
          'Le chêne vert produit des glands utilisés pour nourrir le bétail. Son bois est dur et résistant, utilisé en charpente.',
      'Ficus carica':
          'Le figuier produit des figues fraîches ou séchées, riches en fibres et minéraux. Le latex du figuier a des usages médicinaux traditionnels.',
      'Opuntia ficus-indica':
          'Le figuier de barbarie produit des fruits riches en vitamines. Les raquettes sont utilisées fourrage et les fleurs en tisane.',
      'Allium sativum':
          'L\'ail est utilisé comme condiment et en médecine traditionnelle pour ses propriétés antibiotiques et cardiovasculaires.',
      'Ocimum basilicum':
          'Le basilic est utilisé comme herbe aromatique en cuisine et possède des propriétés anti-inflammatoires.',
      'Helianthus annuus':
          'Le tournesol produit des graines riches en huile, utilisées en alimentation et pour la production d\'huile végétale.',
      'Jasminum':
          'Le jasmin est cultivé pour ses fleurs parfumées utilisées en parfumerie et pour faire le thé au jasmin.',
      'Nerium oleander':
          'Attention: Le laurier-rose est toxique. Il est utilisé uniquement comme plante ornementale malgré sa beauté.',
    };

    return usageInfo[scientificName] ??
        'Cette plante a été identifiée par notre système d\'intelligence artificielle. ' +
            'Elle fait partie de la flore de la région. Pour plus d\'informations sur ses utilisations traditionnelles ' +
            'et ses propriétés, nous vous recommandons de consulter des ouvrages spécialisés sur la flore locale.';
  }

  String _getPlantOrigin(String scientificName) {
    final Map<String, String> originInfo = {
      'Argania spinosa':
          'Endémique du Maroc, l\'arganier pousse principalement dans la région du Souss et l\'Anti-Atlas.',
      'Olea europaea':
          'Originaire du bassin méditerranéen, l\'olivier est cultivé au Maroc depuis des millénaires.',
      'Punica granatum':
          'Originaire de la Perse antique, le grenadier est cultivé au Maroc dans les régions tempérées.',
      'Cedrus atlantica':
          'Endémique de l\'Atlas marocain et de l\'Algérie, le cèdre de l\'Atlas forme de majestueuses forêts.',
      'Quercus ilex':
          'Originaire du bassin méditerranéen, le chêne vert est très répandu dans les forêts marocaines.',
      'Opuntia ficus-indica':
          'Originaire du Mexique, le figuier de barbarie a été introduit au Maroc où il s\'est naturalisé.',
    };

    return originInfo[scientificName] ??
        'Cette plante fait partie de la diversité végétale de la région. ' +
            'Elle s\'est adaptée au climat local et contribue à l\'écosystème.';
  }

  double _getConfidence() {
    return widget.identification.containsKey('latestConfidence')
        ? widget.identification['latestConfidence']
        : widget.identification['confidence'] ?? 0;
  }

  DateTime _getDate() {
    return widget.identification.containsKey('latestDate')
        ? DateTime.parse(widget.identification['latestDate'])
        : DateTime.parse(widget.identification['date']);
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.identification['plant'];
    final scientificName = plant['scientificName'] ?? '';

    // Handle family field that might be a list or string
    String family = 'Famille inconnue';
    if (plant['family'] != null) {
      if (plant['family'] is List) {
        final familyList = plant['family'] as List;
        family = familyList.isNotEmpty
            ? familyList.first.toString()
            : 'Famille inconnue';
      } else {
        family = plant['family'].toString();
      }
    }
    final images = _getPlantImages();
    final darijaName = PlantTranslations.getDarijaName(scientificName);
    final tamazightName = PlantTranslations.getTamazightName(scientificName);
    final confidence = _getConfidence();
    final date = _getDate();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(plant['name'] ?? 'Plante'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Gallery
            if (images.isNotEmpty) _buildImageGallery(images),

            // Plant Information Card
            _buildPlantInfoCard(plant, scientificName, darijaName,
                tamazightName, confidence, family),

            // Usage Information Card
            _buildUsageCard(scientificName),

            // Origin Information Card
            _buildOriginCard(scientificName),

            // Technical Information Card
            _buildTechnicalCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.length == 1) {
      return Container(
        height: 250,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            images[0],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.eco, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 250,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.eco, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentImageIndex == index
                    ? Colors.green
                    : Colors.grey.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantInfoCard(
      Map<String, dynamic> plant,
      String scientificName,
      String darijaName,
      String tamazightName,
      double confidence,
      String family) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Informations sur la plante',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nom commun', plant['name'] ?? ''),
            if (scientificName.isNotEmpty)
              _buildInfoRow('Nom scientifique', scientificName, isItalic: true),
            if (family.isNotEmpty && family != 'Famille inconnue')
              _buildInfoRow('Famille', family),
            if (darijaName.isNotEmpty && darijaName != scientificName)
              _buildInfoRow('Nom (Darija)', darijaName),
            if (tamazightName.isNotEmpty && tamazightName != darijaName)
              _buildInfoRow('Nom (Tamazight)', tamazightName),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Confiance: ${(confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(String scientificName) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Usages et propriétés',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getPlantUsage(scientificName),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginCard(String scientificName) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Origine et distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getPlantOrigin(scientificName),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalCard() {
    final date = _getDate();
    final identificationCount =
        widget.identification.containsKey('identificationCount')
            ? widget.identification['identificationCount']
            : 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.grey, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Informations techniques',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Date d\'identification',
                '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
            if (identificationCount > 1)
              _buildInfoRow(
                  'Nombre d\'identifications', '$identificationCount'),
            _buildInfoRow(
                'Source',
                widget.identification.containsKey('sources')
                    ? widget.identification['sources'][0] ?? 'plantnet'
                    : widget.identification['source'] ?? 'plantnet'),
            _buildInfoRow(
                'ID',
                widget.identification.containsKey('identificationIds')
                    ? widget.identification['identificationIds'][0]
                            ?.toString()
                            .substring(0, 8) ??
                        ''
                    : widget.identification['id']?.toString().substring(0, 8) ??
                        ''),
            if (widget.identification.containsKey('notes') &&
                widget.identification['notes'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              ...widget.identification['notes'].map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  )),
            ] else if (widget.identification['notes'] != null &&
                widget.identification['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.identification['notes'].toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
