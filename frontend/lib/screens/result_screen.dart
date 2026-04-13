import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../data/plant_translations.dart';
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
            // Scientific name
            Card(
              child: ListTile(
                leading: const Icon(Icons.science),
                title: const Text('Nom scientifique'),
                subtitle: Text(plant.scientificName),
              ),
            ),

            // DARIJA NAME (New)
            Card(
              child: ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('بالدارجة',
                    style: TextStyle(fontFamily: 'Arabic')),
                subtitle: Text(
                  plant.darijaName,
                  style: const TextStyle(fontSize: 18, fontFamily: 'Arabic'),
                ),
                trailing: plant.darijaName != plant.scientificName
                    ? null
                    : const Icon(Icons.hourglass_empty, size: 16),
              ),
            ),

            // TAMAZIGHT NAME (New)
            Card(
              child: ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('ⵜⴰⵎⴰⵣⵉⵖⵜ',
                    style: TextStyle(fontFamily: 'Tifinagh')),
                subtitle: Text(
                  plant.tamazightName,
                  style: const TextStyle(fontSize: 18, fontFamily: 'Tifinagh'),
                ),
                trailing: plant.tamazightName != plant.scientificName
                    ? null
                    : const Icon(Icons.hourglass_empty, size: 16),
              ),
            ),

            // Family
            Card(
              child: ListTile(
                leading: const Icon(Icons.family_restroom),
                title: const Text('Famille'),
                subtitle: Text(plant.family),
              ),
            ),

            // Confidence
            Card(
              child: ListTile(
                leading: const Icon(Icons.percent),
                title: const Text('Confiance'),
                subtitle: Text('${plant.confidencePercentage}%'),
              ),
            ),

            const SizedBox(height: 16),

            // Contribute translation (optional)
            if (!PlantTranslations.hasTranslation(plant.scientificName))
              Center(
                child: TextButton.icon(
                  onPressed: () => _suggestTranslation(context),
                  icon: const Icon(Icons.contact_support, size: 16),
                  label:
                      const Text('Proposer une traduction en Darija/Tamazight'),
                ),
              ),

            const SizedBox(height: 24),

            // Bottom buttons
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

  void _suggestTranslation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Proposer une traduction'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cette plante n\'a pas encore de nom en Darija ou Tamazight.'),
            SizedBox(height: 16),
            Text('Souhaitez-vous proposer une traduction ?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Open form to submit translation
              Navigator.pop(context);
            },
            child: const Text('Proposer'),
          ),
        ],
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
