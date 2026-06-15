import 'package:flutter/material.dart';
import '../data/plant_translations.dart';
import '../utils/constants.dart';
import '../models/plant.dart';
import '../widgets/app_theme.dart';
import 'share_from_history_screen.dart';
import 'translation_proposal_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> identification;

  const PlantDetailScreen({super.key, required this.identification});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  int _currentImageIndex = 0;
  List<String> _allDarijaNames = [];
  List<String> _allTamazightNames = [];
  bool _isLoadingTranslations = true;

  @override
  void initState() {
    super.initState();
    _loadAllTranslations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh translations when returning to this screen (in case user just added a new translation)
    _loadAllTranslations();
  }

  Future<void> _loadAllTranslations() async {
    final plant = widget.identification['plant'];
    final scientificName = plant['scientificName'] ?? '';

    if (scientificName.isNotEmpty) {
      try {
        final darijaNames =
            await PlantTranslations.getAllDarijaNames(scientificName);
        final tamazightNames =
            await PlantTranslations.getAllTamazightNames(scientificName);

        setState(() {
          _allDarijaNames = darijaNames;
          _allTamazightNames = tamazightNames;
          _isLoadingTranslations = false;
        });
      } catch (e) {
        print('Error loading translations: $e');
        setState(() {
          _isLoadingTranslations = false;
        });
      }
    } else {
      setState(() {
        _isLoadingTranslations = false;
      });
    }
  }

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

  double _getConfidence() {
    return widget.identification.containsKey('latestConfidence')
        ? widget.identification['latestConfidence']
        : widget.identification['confidence'] ?? 0;
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
    final confidence = _getConfidence();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text(plant['name'] ?? 'Plante'),
        backgroundColor: AppTheme.primary,
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
            _buildPlantInfoCard(plant, scientificName, confidence, family),

            // Share with community button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  final images = _getPlantImages();
                  if (images.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShareFromHistoryScreen(
                          identification: widget.identification,
                          imageUrl: images[0],
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Partager avec la communauté'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),
            ),

            // Proposer traduction button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => _navigateToTranslationProposal(),
                icon: const Icon(Icons.translate, size: 20),
                label: const Text('Proposer traduction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.length == 1) {
      return Container(
        height: 280,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Image.network(
            images[0],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppTheme.primarySurface,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppTheme.primarySurface,
              child: const Center(
                child: Icon(Icons.eco, size: 50, color: AppTheme.primary),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 280,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppTheme.primarySurface,
                      child: const Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.primary),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.primarySurface,
                    child: const Center(
                      child: Icon(Icons.eco, size: 50, color: AppTheme.primary),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
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
                    ? AppTheme.primary
                    : AppTheme.textHint,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantInfoCard(Map<String, dynamic> plant, String scientificName,
      double confidence, String family) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(Icons.eco, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Informations sur la plante',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                // Small refresh button
                InkWell(
                  onTap: () async {
                    setState(() => _isLoadingTranslations = true);
                    await PlantTranslations.refreshTranslations(scientificName);
                    _loadAllTranslations();
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: _isLoadingTranslations
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          )
                        : Icon(Icons.refresh,
                            color: AppTheme.primary, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Nom commun', plant['name'] ?? ''),
            if (scientificName.isNotEmpty)
              _buildInfoRow('Nom scientifique', scientificName, isItalic: true),
            if (family.isNotEmpty && family != 'Famille inconnue')
              _buildInfoRow('Famille', family),
            ..._buildTranslationRows(scientificName),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Confiance: ${(confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  Widget _buildInfoRow(String label, String value, {bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
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
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTranslationRows(String scientificName) {
    List<Widget> rows = [];

    // Display all Darija translations
    if (_isLoadingTranslations) {
      rows.add(_buildInfoRow('Nom (Darija)', 'Chargement...'));
    } else if (_allDarijaNames.isNotEmpty) {
      for (int i = 0; i < _allDarijaNames.length; i++) {
        rows.add(_buildInfoRow(
            i == 0 ? 'Nom (Darija)' : 'Nom (Darija) ${i + 1}',
            _allDarijaNames[i]));
      }
    } else {
      final fallbackDarija =
          PlantTranslations.getDarijaNameSync(scientificName);
      if (fallbackDarija.isNotEmpty && fallbackDarija != scientificName) {
        rows.add(_buildInfoRow('Nom (Darija)', fallbackDarija));
      }
    }

    // Display all Tamazight translations
    if (_isLoadingTranslations) {
      rows.add(_buildInfoRow('Nom (Tamazight)', 'Chargement...'));
    } else if (_allTamazightNames.isNotEmpty) {
      for (int i = 0; i < _allTamazightNames.length; i++) {
        rows.add(_buildInfoRow(
            i == 0 ? 'Nom (Tamazight)' : 'Nom (Tamazight) ${i + 1}',
            _allTamazightNames[i]));
      }
    } else {
      final fallbackTamazight =
          PlantTranslations.getTamazightNameSync(scientificName);
      if (fallbackTamazight.isNotEmpty && fallbackTamazight != scientificName) {
        rows.add(_buildInfoRow('Nom (Tamazight)', fallbackTamazight));
      }
    }

    return rows;
  }

  void _navigateToTranslationProposal() {
    // Extract plant data from identification
    final plantData = widget.identification.containsKey('plant')
        ? widget.identification['plant']
        : widget.identification;

    // Create a Plant object
    final plant = Plant(
      id: plantData['_id']?.toString() ?? '',
      name: plantData['name']?.toString() ?? 'Unknown Plant',
      scientificName: plantData['scientificName']?.toString() ?? '',
      family: plantData['family']?.toString() ?? 'Unknown Family',
      confidence: 0.0, // Default confidence since it's not in detail data
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranslationProposalScreen(plant: plant),
      ),
    );
  }
}
