import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../services/gbif_service.dart';

// Enum for map view types
enum MapViewType {
  heatmap,
  markers,
  circles,
  clusters,
}

class PlantMapScreen extends StatefulWidget {
  final String plantName;
  final String scientificName;

  const PlantMapScreen({
    Key? key,
    required this.plantName,
    required this.scientificName,
  }) : super(key: key);

  @override
  State<PlantMapScreen> createState() => _PlantMapScreenState();
}

class _PlantMapScreenState extends State<PlantMapScreen> {
  List<Map<String, dynamic>> _occurrences = [];
  bool _isLoading = true;
  int _totalCount = 0;
  String _error = '';
  MapViewType _currentViewType = MapViewType.heatmap; // Default view
  String? _selectedCountry;
  int? _selectedYear;
  bool _showFilters = false;
  List<String> _availableCountries = [];
  List<int> _availableYears = [];

  final List<Map<String, String>> _commonCountries = [
    {'code': 'FR', 'name': 'France'},
    {'code': 'US', 'name': 'États-Unis'},
    {'code': 'GB', 'name': 'Royaume-Uni'},
    {'code': 'DE', 'name': 'Allemagne'},
    {'code': 'ES', 'name': 'Espagne'},
    {'code': 'IT', 'name': 'Italie'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'AU', 'name': 'Australie'},
    {'code': 'BR', 'name': 'Brésil'},
    {'code': 'IN', 'name': 'Inde'},
    {'code': 'CN', 'name': 'Chine'},
    {'code': 'JP', 'name': 'Japon'},
    {'code': 'ZA', 'name': 'Afrique du Sud'},
    {'code': 'MA', 'name': 'Maroc'},
  ];

// Available years (last 10 years)
  final List<int> _availableYearsList =
      List.generate(11, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();
    _loadOccurrences();
  }

// Method to apply filters
  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
      _showFilters = false;
    });

    final result = await GBIFService.getOccurrences(
      widget.scientificName,
      limit: 200,
      country: _selectedCountry,
      year: _selectedYear,
    );

    if (result['success'] == true) {
      setState(() {
        _occurrences =
            List<Map<String, dynamic>>.from(result['occurrences'] ?? []);
        _totalCount = result['totalCount'] ?? 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Erreur lors du filtrage';
        _isLoading = false;
      });
    }
  }

// Method to reset filters
  void _resetFilters() {
    setState(() {
      _selectedCountry = null;
      _selectedYear = null;
    });
    _applyFilters();
  }

// Method to show filter dialog
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Filtrer les observations',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Country filter
                  const Text('🌍 Pays',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountry,
                        hint: const Text('Tous les pays'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('🌍 Tous les pays')),
                          ..._commonCountries.map((country) => DropdownMenuItem(
                                value: country['code'],
                                child: Text(
                                    '${country['name']} (${country['code']})'),
                              )),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            _selectedCountry = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Year filter
                  const Text('📅 Année',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        hint: const Text('Toutes les années'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('📅 Toutes les années')),
                          ..._availableYearsList.map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              )),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            _selectedYear = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _resetFilters();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _applyFilters();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Active filters indicator
                  if (_selectedCountry != null || _selectedYear != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Filtres actifs: ${_selectedCountry != null ? "Pays: $_selectedCountry" : ""}${_selectedCountry != null && _selectedYear != null ? " • " : ""}${_selectedYear != null ? "Année: $_selectedYear" : ""}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadOccurrences() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result =
        await GBIFService.getOccurrences(widget.scientificName, limit: 200);

    // Check if the error is a 503 (GBIF busy)
    if (result['success'] == false &&
        result['message']?.contains('503') == true) {
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Service temporairement indisponible'),
          content: const Text(
              'Le service de distribution de GBIF est actuellement surchargé.\n\n'
              'Veuillez réessayer dans quelques minutes.\n\n'
              'Les données de distribution seront disponibles ultérieurement.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (result['success'] == true) {
      setState(() {
        _occurrences =
            List<Map<String, dynamic>>.from(result['occurrences'] ?? []);
        _totalCount = result['totalCount'] ?? 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Service temporairement indisponible';
        _isLoading = false;
      });
    }
  }

  String _getViewTypeName() {
    switch (_currentViewType) {
      case MapViewType.heatmap:
        return '🔥 Carte de chaleur';
      case MapViewType.markers:
        return '📍 Points individuels';
      case MapViewType.circles:
        return '⚪ Cercles transparents';
      case MapViewType.clusters:
        return '📦 Regroupement';
    }
  }

  IconData _getViewTypeIcon() {
    switch (_currentViewType) {
      case MapViewType.heatmap:
        return Icons.heat_pump;
      case MapViewType.markers:
        return Icons.place;
      case MapViewType.circles:
        return Icons.circle;
      case MapViewType.clusters:
        return Icons.groups;
    }
  }

  void _changeViewType() {
    setState(() {
      // Cycle through view types
      switch (_currentViewType) {
        case MapViewType.heatmap:
          _currentViewType = MapViewType.markers;
          break;
        case MapViewType.markers:
          _currentViewType = MapViewType.circles;
          break;
        case MapViewType.circles:
          _currentViewType = MapViewType.clusters;
          break;
        case MapViewType.clusters:
          _currentViewType = MapViewType.heatmap;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distribution: ${widget.plantName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrer',
          ),
          // View type selector
          IconButton(
            icon: Icon(_getViewTypeIcon()),
            onPressed: _changeViewType,
            tooltip: 'Changer le type de vue',
          ),
          // View type name
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getViewTypeName(),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOccurrences,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _occurrences.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucune donnée de distribution disponible',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pour: ${widget.scientificName}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : _buildMap(),
    );
  }

  Widget _buildMap() {
    double centerLat = _occurrences.fold(0.0, (sum, p) => sum + p['lat']) /
        _occurrences.length;
    double centerLng = _occurrences.fold(0.0, (sum, p) => sum + p['lng']) /
        _occurrences.length;

    final List<WeightedLatLng> heatmapPoints = _occurrences
        .map((point) => WeightedLatLng(LatLng(point['lat'], point['lng']), 1.0))
        .toList();

    return Column(
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.green.shade50,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '🌍 ${_occurrences.length} observations sur $_totalCount au total',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getViewTypeColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getViewTypeName(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              // Show active filters
              if (_selectedCountry != null || _selectedYear != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Filtré: ${_selectedCountry != null ? "Pays: ${_commonCountries.firstWhere((c) => c['code'] == _selectedCountry, orElse: () => {
                                'name': _selectedCountry!
                              })['name']}" : ""}${_selectedCountry != null && _selectedYear != null ? " • " : ""}${_selectedYear != null ? "Année: $_selectedYear" : ""}',
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resetFilters,
                        child: const Icon(Icons.close,
                            size: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Map
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(centerLat, centerLng),
              initialZoom: 3,
            ),
            children: [
              // Base map tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sfe_mobile',
              ),

              // Select view type
              if (_currentViewType == MapViewType.heatmap)
                _buildHeatmapLayer(heatmapPoints),
              if (_currentViewType == MapViewType.markers) _buildMarkersLayer(),
              if (_currentViewType == MapViewType.circles) _buildCirclesLayer(),
              if (_currentViewType == MapViewType.clusters)
                _buildClustersLayer(),
            ],
          ),
        ),
      ],
    );
  }

  Color _getViewTypeColor() {
    switch (_currentViewType) {
      case MapViewType.heatmap:
        return Colors.orange;
      case MapViewType.markers:
        return Colors.red;
      case MapViewType.circles:
        return Colors.purple;
      case MapViewType.clusters:
        return Colors.blue;
    }
  }

  // Option 1: Heatmap
  Widget _buildHeatmapLayer(List<WeightedLatLng> heatmapPoints) {
    return HeatMapLayer(
      heatMapDataSource: InMemoryHeatMapDataSource(data: heatmapPoints),
      heatMapOptions: HeatMapOptions(
        gradient: {
          0.1: Colors.blue,
          0.3: Colors.yellow,
          0.6: Colors.red,
          1.0: Colors.purple,
        },
        minOpacity: 0.4,
        radius: 40,
      ),
    );
  }

  // Option 2: Individual Markers (Pins)
  Widget _buildMarkersLayer() {
    return MarkerLayer(
      markers: _occurrences.map((point) {
        return Marker(
          width: 40,
          height: 40,
          point: LatLng(point['lat'], point['lng']),
          child: GestureDetector(
            onTap: () => _showLocationDialog(point),
            child: const Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 35,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Option 3: Transparent Circles (Heatmap-like but with circles)
  Widget _buildCirclesLayer() {
    return MarkerLayer(
      markers: _occurrences.map((point) {
        // Randomize opacity for density effect
        final opacity = 0.2 + (point['lat'] % 0.3);

        return Marker(
          width: 25,
          height: 25,
          point: LatLng(point['lat'], point['lng']),
          child: GestureDetector(
            onTap: () => _showLocationDialog(point),
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(opacity),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 1),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Option 4: Clusters (Groups nearby points)
  Widget _buildClustersLayer() {
    // Convert occurrences to markers
    final markers = _occurrences.map((point) {
      return Marker(
        width: 40,
        height: 40,
        point: LatLng(point['lat'], point['lng']),
        child: GestureDetector(
          onTap: () => _showLocationDialog(point),
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 35,
          ),
        ),
      );
    }).toList();

    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: 120,
        size: const Size(40, 40),
        markers: markers,
        builder: (context, markers) {
          return GestureDetector(
            onTap: () {
              // Optional: Show cluster info when tapped
              print('Cluster with ${markers.length} points');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  markers.length.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
        spiderfySpiralDistanceMultiplier: 2,
      ),
    );
  }

  void _showLocationDialog(Map<String, dynamic> point) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Observation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (point['country'] != null) Text('🌍 Pays: ${point['country']}'),
            if (point['locality'] != null)
              Text('📍 Lieu: ${point['locality']}'),
            if (point['year'] != null) Text('📅 Année: ${point['year']}'),
            Text('🗺️ Coordonnées: ${point['lat']}, ${point['lng']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
