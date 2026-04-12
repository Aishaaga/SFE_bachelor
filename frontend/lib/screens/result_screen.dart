import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import 'history_screen.dart';
import 'plant_map_screen.dart';

class ResultScreen extends StatelessWidget {
  final Plant plant;
  final File photo;
  final String identificationId;

  const ResultScreen({
    super.key,
    required this.plant,
    required this.photo,
    required this.identificationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Résultat'),
          centerTitle: true,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          // Add this button where you display the plant info
          actions: [
            ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlantMapScreen(
                        plantName: plant.name,
                        scientificName: plant.scientificName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('Voir la distribution mondiale'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                )),
          ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(photo,
                    height: 250, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco, color: Colors.green, size: 30),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (plant.scientificName.isNotEmpty)
                                Text(
                                  plant.scientificName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    if (plant.family.isNotEmpty)
                      _infoRow(Icons.category, 'Famille', plant.family),
                    if (plant.localName != null)
                      _infoRow(Icons.language, 'Nom local', plant.localName!),
                    _infoRow(
                      Icons.analytics,
                      'Confiance',
                      '${(plant.confidence * 100).toStringAsFixed(1)}%',
                    ),
                    _infoRow(
                      Icons.fingerprint,
                      'ID',
                      identificationId.substring(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Nouvelle photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Voir historique'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
