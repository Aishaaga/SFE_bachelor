import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../data/plant_translations.dart';
import 'history_screen.dart';
import 'plant_map_screen.dart';
import 'translation_proposal_screen.dart';
import 'share_screen.dart';

class ResultScreen extends StatefulWidget {
  final Plant plant;
  final File photo;
  final String? identificationId;

  const ResultScreen({
    super.key,
    required this.plant,
    required this.photo,
    this.identificationId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<String> _darijaNames = [];
  List<String> _tamazightNames = [];
  bool _isLoadingTranslations = true;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    try {
      // Clear cache for this plant to get fresh data
      PlantTranslations.clearDatabaseCacheEntry(widget.plant.scientificName);

      // Get all translations from database
      final darijaNames = await PlantTranslations.getAllDarijaNames(
          widget.plant.scientificName);
      final tamazightNames = await PlantTranslations.getAllTamazightNames(
          widget.plant.scientificName);

      if (mounted) {
        setState(() {
          _darijaNames = darijaNames;
          _tamazightNames = tamazightNames;
          _isLoadingTranslations = false;
        });
      }
    } catch (e) {
      print('Error loading translations: $e');
      if (mounted) {
        setState(() {
          _darijaNames = [widget.plant.darijaName]; // Fallback to sync
          _tamazightNames = [widget.plant.tamazightName]; // Fallback to sync
          _isLoadingTranslations = false;
        });
      }
    }
  }

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
                        plantName: widget.plant.name,
                        scientificName: widget.plant.scientificName,
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
                child: Image.file(widget.photo,
                    height: 250, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),
            // Scientific name
            Card(
              child: ListTile(
                leading: const Icon(Icons.science),
                title: const Text('Nom scientifique'),
                subtitle: Text(widget.plant.scientificName),
              ),
            ),

            // DARIJA NAMES (Multiple)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: Row(
                      children: [
                        const Text('بالدارجة',
                            style: TextStyle(fontFamily: 'Arabic')),
                        const Spacer(),
                        if (!_isLoadingTranslations)
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            onPressed: () {
                              setState(() {
                                _isLoadingTranslations = true;
                              });
                              _loadTranslations();
                            },
                            tooltip: 'Actualiser les traductions',
                          ),
                      ],
                    ),
                    subtitle: _isLoadingTranslations
                        ? const CircularProgressIndicator()
                        : _darijaNames.isEmpty
                            ? Text(widget.plant.darijaName,
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: 'Arabic'))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _darijaNames
                                    .map((name) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Icon(Icons.circle,
                                                  size: 8,
                                                  color: Colors.green[700]),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(name,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontFamily: 'Arabic')),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                  ),
                  if (_darijaNames.length > 1)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('${_darijaNames.length} noms disponibles',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ),
                ],
              ),
            ),

            // TAMAZIGHT NAMES (Multiple)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: const Text('ⵜⴰⵎⴰⵣⵉⵖⵜ',
                        style: TextStyle(fontFamily: 'Tifinagh')),
                    subtitle: _isLoadingTranslations
                        ? const CircularProgressIndicator()
                        : _tamazightNames.isEmpty
                            ? Text(widget.plant.tamazightName,
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: 'Tifinagh'))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _tamazightNames
                                    .map((name) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Icon(Icons.circle,
                                                  size: 8,
                                                  color: Colors.blue[700]),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(name,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            'Tifinagh')),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                  ),
                  if (_tamazightNames.length > 1)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('${_tamazightNames.length} noms disponibles',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ),
                ],
              ),
            ),

            // Family
            Card(
              child: ListTile(
                leading: const Icon(Icons.family_restroom),
                title: const Text('Famille'),
                subtitle: Text(widget.plant.family),
              ),
            ),

            // Confidence
            Card(
              child: ListTile(
                leading: const Icon(Icons.percent),
                title: const Text('Confiance'),
                subtitle: Text('${widget.plant.confidencePercentage}%'),
              ),
            ),

            const SizedBox(height: 16),

            // Contribute translation (optional)
            if (_shouldShowTranslationButton())
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
            Column(
              children: [
                // Share with community button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShareScreen(
                            plant: widget.plant,
                            photo: widget.photo,
                            identificationId: widget.identificationId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share with community'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Existing buttons row
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
          ],
        ),
      ),
    );
  }

  bool _shouldShowTranslationButton() {
    // Always show the translation proposal button
    return true;
  }

  void _suggestTranslation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TranslationProposalScreen(plant: widget.plant),
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
