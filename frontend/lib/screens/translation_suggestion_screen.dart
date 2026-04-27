import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plant.dart';
import '../models/translation_suggestion.dart';
import '../services/proposal_service.dart';

class TranslationSuggestionScreen extends StatefulWidget {
  final Plant plant;

  const TranslationSuggestionScreen({
    super.key,
    required this.plant,
  });

  @override
  State<TranslationSuggestionScreen> createState() => _TranslationSuggestionScreenState();
}

class _TranslationSuggestionScreenState extends State<TranslationSuggestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _darijaController = TextEditingController();
  final _tamazightController = TextEditingController();
  final _contributorNameController = TextEditingController();
  final _contributorEmailController = TextEditingController();
  final _regionController = TextEditingController();
  final _notesController = TextEditingController();

  bool _proposeDarija = false;
  bool _proposeTamazight = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _darijaController.dispose();
    _tamazightController.dispose();
    _contributorNameController.dispose();
    _contributorEmailController.dispose();
    _regionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_proposeDarija && !_proposeTamazight) {
      _showErrorDialog('Veuillez sélectionner au moins une langue à proposer');
      return;
    }

    if (_proposeDarija && _darijaController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez entrer une traduction en Darija');
      return;
    }

    if (_proposeTamazight && _tamazightController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez entrer une traduction en Tamazight');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final suggestion = TranslationSuggestion(
        id: _generateId(),
        scientificName: widget.plant.scientificName,
        darijaProposal: _proposeDarija ? _darijaController.text.trim() : null,
        tamazightProposal: _proposeTamazight ? _tamazightController.text.trim() : null,
        contributorName: _contributorNameController.text.trim(),
        contributorEmail: _contributorEmailController.text.trim(),
        region: _regionController.text.trim(),
        notes: _notesController.text.trim(),
        submittedAt: DateTime.now(),
      );

      await ProposalService.saveSuggestion(suggestion);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors de la soumission: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Votre suggestion de traduction a été soumise avec succès!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggérer une traduction - ${widget.plant.scientificName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plant.scientificName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Proposez une traduction pour cette plante',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Language selection
              Text(
                'Langues à proposer',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Darija (Marocain Arabe)'),
                subtitle: const Text('Proposer une traduction en Darija'),
                value: _proposeDarija,
                onChanged: (value) {
                  setState(() {
                    _proposeDarija = value!;
                  });
                },
              ),
              if (_proposeDarija) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _darijaController,
                  decoration: const InputDecoration(
                    labelText: 'Traduction en Darija',
                    hintText: 'Entrez la traduction en Darija',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ],
              CheckboxListTile(
                title: const Text('Tamazight'),
                subtitle: const Text('Proposer une traduction en Tamazight'),
                value: _proposeTamazight,
                onChanged: (value) {
                  setState(() {
                    _proposeTamazight = value!;
                  });
                },
              ),
              if (_proposeTamazight) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tamazightController,
                  decoration: const InputDecoration(
                    labelText: 'Traduction en Tamazight',
                    hintText: 'ⵜⴰⵎⴰⵣⵉⵖⵜ - Entrez la traduction en Tamazight',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ],
              const SizedBox(height: 24),

              // Contributor information
              Text(
                'Vos informations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contributorNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  hintText: 'Entrez votre nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contributorEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Entrez votre email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: 'Région (optionnel)',
                  hintText: 'Ex: Rabat, Casablanca, Marrakech...',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes additionnelles (optionnel)',
                  hintText: 'Informations complémentaires sur votre traduction',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Soumission en cours...'),
                          ],
                        )
                      : const Text(
                          'Soumettre la suggestion',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
