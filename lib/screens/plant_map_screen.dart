import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/gbif_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadOccurrences();
  }

  Future<void> _loadOccurrences() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await GBIFService.getOccurrences(widget.scientificName);

    if (result['success'] == true) {
      setState(() {
        _occurrences =
            List<Map<String, dynamic>>.from(result['occurrences'] ?? []);
        _totalCount = result['totalCount'] ?? 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Erreur inconnue';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distribution: ${widget.plantName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
    // Calculate center for initial view
    double centerLat = _occurrences.fold(0.0, (sum, p) => sum + p['lat']) /
        _occurrences.length;
    double centerLng = _occurrences.fold(0.0, (sum, p) => sum + p['lng']) /
        _occurrences.length;

    return Column(
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.green.shade50,
          child: Text(
            '🌍 ${_occurrences.length} observations sur $_totalCount au total',
            style: const TextStyle(fontSize: 14),
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
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sfe_mobile',
              ),
              MarkerLayer(
                markers: _occurrences.map((point) {
                  return Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(point['lat'], point['lng']),
                    child: GestureDetector(
                      onTap: () {
                        _showLocationDialog(point);
                      },
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
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
