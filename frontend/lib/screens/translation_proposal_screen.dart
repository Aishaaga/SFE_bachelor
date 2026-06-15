import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plant.dart';
import '../models/translation_suggestion.dart';
import '../services/proposal_service.dart';
import '../services/auth_service.dart';
import '../data/plant_translations.dart';
import '../widgets/app_theme.dart';

class TranslationProposalScreen extends StatefulWidget {
  final Plant plant;

  const TranslationProposalScreen({
    super.key,
    required this.plant,
  });

  @override
  State<TranslationProposalScreen> createState() =>
      _TranslationProposalScreenState();
}

class _TranslationProposalScreenState extends State<TranslationProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _darijaController = TextEditingController();
  final _tamazightController = TextEditingController();
  final _regionController = TextEditingController();
  final _notesController = TextEditingController();
  final _authService = AuthService();

  bool _isSubmitting = false;
  bool _proposeDarija = true;
  bool _proposeTamazight = true;
  String? _userEmail;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _darijaController.dispose();
    _tamazightController.dispose();
    _regionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final email = await _authService.getCurrentUserEmail();
      if (email != null) {
        setState(() {
          _userEmail = email;
          // Extract name from email (before @ symbol) or use full email as name
          _userName = email.split('@')[0];
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_proposeDarija && !_proposeTamazight) {
      _showErrorDialog(
          'Veuillez proposer au moins une traduction (Darija ou Tamazight)');
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

    // Vérifier si l'utilisateur est connecté
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    if (!isLoggedIn) {
      _showErrorDialog(
          'Vous devez être connecté pour soumettre une traduction');
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
        tamazightProposal:
            _proposeTamazight ? _tamazightController.text.trim() : null,
        contributorName: _userName ?? 'Anonymous',
        contributorEmail: _userEmail ?? 'anonymous@example.com',
        region: _regionController.text.trim(),
        notes: _notesController.text.trim(),
        submittedAt: DateTime.now(),
      );

      await ProposalService.saveProposal(suggestion);

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
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(10000);
    return 'proposal_${timestamp}_$randomNum';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Merci!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Votre proposition de traduction a été soumise avec succès.\n'
          'Elle sera examinée par notre équipe avant d\'être validée.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear cache for this plant to ensure fresh data on return
              PlantTranslations.clearDatabaseCacheEntry(
                  widget.plant.scientificName);

              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Erreur',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.refusedText,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
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
          'Proposer une traduction',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant info card
              Container(
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
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Icon(Icons.eco,
                                color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.plant.scientificName,
                              style: AppTheme.plantName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Famille: ${widget.plant.family}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Translation options
              Text(
                'Quelles traductions souhaitez-vous proposer?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: Text(
                        'Darija (Marocain Arabe)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Traduction en arabe marocain',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      value: _proposeDarija,
                      onChanged: (value) {
                        if (value == false && !_proposeTamazight) {
                          return;
                        }
                        setState(() {
                          _proposeDarija = value ?? true;
                        });
                      },
                      activeColor: AppTheme.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    Divider(height: 1, color: AppTheme.divider),
                    CheckboxListTile(
                      title: Text(
                        'Tamazight',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Traduction en berbère marocain',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      value: _proposeTamazight,
                      onChanged: (value) {
                        if (value == false && !_proposeDarija) {
                          return;
                        }
                        setState(() {
                          _proposeTamazight = value ?? true;
                        });
                      },
                      activeColor: AppTheme.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Darija translation field
              if (_proposeDarija) ...[
                TextFormField(
                  controller: _darijaController,
                  decoration: InputDecoration(
                    labelText: 'Traduction en Darija',
                    hintText: 'Entrez le nom en arabe marocain',
                    prefixIcon: Icon(Icons.translate, color: AppTheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      borderSide:
                          const BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AppTheme.cardBg,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Arabic'),
                  validator: (value) {
                    if (_proposeDarija &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Tamazight translation field
              if (_proposeTamazight) ...[
                TextFormField(
                  controller: _tamazightController,
                  decoration: InputDecoration(
                    labelText: 'Traduction en Tamazight',
                    hintText: 'Entrez le nom en tamazight',
                    prefixIcon: Icon(Icons.translate, color: AppTheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      borderSide: const BorderSide(color: AppTheme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      borderSide:
                          const BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AppTheme.cardBg,
                  ),
                  style: const TextStyle(fontFamily: 'Tifinagh'),
                  validator: (value) {
                    if (_proposeTamazight &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Contributor information (auto-detected)
              Container(
                padding: const EdgeInsets.all(16),
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
                    Icon(
                      Icons.person,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soumis par: ${_userName ?? 'Chargement...'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userEmail ?? 'Chargement...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: InputDecoration(
                  labelText: 'Région (optionnel)',
                  hintText: 'Ex: Rabat, Marrakech, Souss...',
                  prefixIcon: Icon(Icons.location_on, color: AppTheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide:
                        const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardBg,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes supplémentaires (optionnel)',
                  hintText:
                      'Informations additionnelles sur votre traduction...',
                  prefixIcon: Icon(Icons.note_add, color: AppTheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    borderSide:
                        const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardBg,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Soumettre la proposition',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
