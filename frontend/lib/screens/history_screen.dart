import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'plant_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
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
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer cette identification ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete all identifications for this plant group
    bool allDeleted = true;
    String? errorMessage;

    final identificationIds =
        plantGroup['identificationIds'] as List<dynamic>? ?? [];
    for (String identificationId in identificationIds) {
      final result = await _apiService.deleteIdentification(identificationId);
      if (!result['success']) {
        allDeleted = false;
        errorMessage = result['message'];
        break;
      }
    }

    if (allDeleted) {
      await _loadHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Plante supprimée de l\'historique'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(errorMessage ?? 'Erreur lors de la suppression'),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildPlantImageGrid(List<String> photoUrls) {
    if (photoUrls.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.eco, color: Colors.green),
      );
    }

    // Show up to 4 images in a grid
    final displayUrls = photoUrls.take(4).toList();
    final hasMore = photoUrls.length > 4;

    if (displayUrls.length == 1) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Builder(
            builder: (context) {
              final imageUrl =
                  '${Constants.apiUrl.substring(0, Constants.apiUrl.indexOf('/api'))}${displayUrls[0]}';
              return Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.eco, color: Colors.green);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // First image (background)
          if (displayUrls.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Builder(
                  builder: (context) {
                    final imageUrl =
                        '${Constants.apiUrl.substring(0, Constants.apiUrl.indexOf('/api'))}${displayUrls[0]}';
                    return Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[200]);
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
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '+${photoUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon historique'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHistory,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _plants.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Aucune identification',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 8),
                          Text('Prenez une photo pour commencer'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _plants.length,
                      itemBuilder: (context, index) {
                        final plantGroup = _plants[index];
                        final plant = plantGroup['plant'];
                        final latestDate =
                            DateTime.parse(plantGroup['latestDate']);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: _buildPlantImageGrid(List<String>.from(
                                plantGroup['photoUrls'] ?? [])),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    plant['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${plantGroup['identificationCount']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (plant['scientificName'] != null &&
                                    plant['scientificName'].isNotEmpty)
                                  Text(
                                    plant['scientificName'],
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                Text(
                                  'Dernière: ${latestDate.day}/${latestDate.month}/${latestDate.year} ${latestDate.hour}:${latestDate.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (plantGroup['identificationCount'] > 1)
                                  Text(
                                    '${plantGroup['identificationCount']} identifications',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePlantGroup(plantGroup),
                            ),
                            isThreeLine: true,
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
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
