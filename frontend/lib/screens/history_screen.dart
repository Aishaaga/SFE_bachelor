import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../models/plant.dart';
import '../widgets/app_theme.dart';
import 'plant_detail_screen.dart';
import 'translation_proposal_screen.dart';
import 'camera_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _plants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    final result = await _apiService.getHistory();

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _plants = result['plants'] ?? [];
        print('DEBUG: Loaded ${_plants.length} grouped plants');
        for (var plant in _plants) {
          final photoUrls = List<String>.from(plant['photoUrls'] ?? []);
          print(
              'DEBUG: Plant: ${plant['plant']?['name'] ?? 'Unknown'}, count: ${plant['identificationCount'] ?? 0}, photos: ${photoUrls.length}');
        }
      } else {
        _error = result['message'];
      }
    });
  }

  Future<void> _deletePlantGroup(Map<String, dynamic> plantGroup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer toutes les identifications de cette plante ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _apiService.deletePlantGroup(plantGroup['_id']);
      if (result['success']) {
        _loadHistory();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plante supprimée avec succès')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(result['message'] ?? 'Erreur lors de la suppression')),
          );
        }
      }
    }
  }

  Widget _buildPlantImageGrid(List<String> photoUrls) {
    if (photoUrls.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: const Icon(Icons.eco, color: AppTheme.primary),
      );
    }

    // Show up to 4 images in a grid
    final displayUrls = photoUrls.take(4).toList();
    final hasMore = photoUrls.length > 4;

    if (displayUrls.length == 1) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Builder(
            builder: (context) {
              final imageUrl =
                  '${Constants.apiUrl.substring(0, Constants.apiUrl.indexOf('/api'))}${displayUrls[0]}';
              return Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.eco, color: AppTheme.primary);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }

    // Multiple images - show a grid
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Stack(
        children: [
          // First image (background)
          if (displayUrls.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Builder(
                  builder: (context) {
                    final imageUrl =
                        '${Constants.apiUrl.substring(0, Constants.apiUrl.indexOf('/api'))}${displayUrls[0]}';
                    return Image.network(
                      imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: AppTheme.primarySurface);
                      },
                    );
                  },
                ),
              ),
            ),
          // Overlay for multiple images
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Center(
                child: Text(
                  '+${photoUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Mon historique',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error,
                          size: 60, color: AppTheme.refusedText),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHistory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _plants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history,
                              size: 60, color: AppTheme.textHint),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune identification',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prenez une photo pour commencer',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _plants.length,
                      itemBuilder: (context, index) {
                        final plantGroup = _plants[index];
                        final plant = plantGroup['plant'];
                        final latestDate =
                            DateTime.parse(plantGroup['latestDate']);

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlantDetailScreen(
                                      identification: plantGroup,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    _buildPlantImageGrid(List<String>.from(
                                        plantGroup['photoUrls'] ?? [])),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  plant['name'],
                                                  style: AppTheme.plantName,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppTheme.primarySurface,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppTheme.radiusPill),
                                                ),
                                                child: Text(
                                                  '${plantGroup['identificationCount']}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppTheme.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (plant['scientificName'] != null &&
                                              plant['scientificName']
                                                  .isNotEmpty)
                                            Text(
                                              plant['scientificName'],
                                              style: AppTheme.scientificName,
                                            ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Dernière: ${latestDate.day}/${latestDate.month}/${latestDate.year} ${latestDate.hour}:${latestDate.minute.toString().padLeft(2, '0')}',
                                            style: AppTheme.timeAgo,
                                          ),
                                          if (plantGroup[
                                                  'identificationCount'] >
                                              1)
                                            Text(
                                              '${plantGroup['identificationCount']} identifications',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textSecondary,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: AppTheme.refusedText),
                                      onPressed: () =>
                                          _deletePlantGroup(plantGroup),
                                      tooltip: 'Supprimer',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
