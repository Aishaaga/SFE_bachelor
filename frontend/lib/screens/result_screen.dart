// lib/screens/result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../data/plant_translations.dart';
import '../widgets/app_theme.dart';
import '../l10n/app_localizations.dart';
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

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  List<String> _darijaNames = [];
  List<String> _tamazightNames = [];
  bool _isLoadingTranslations = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadTranslations();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTranslations() async {
    setState(() => _isLoadingTranslations = true);
    try {
      PlantTranslations.clearDatabaseCacheEntry(widget.plant.scientificName);
      final darija = await PlantTranslations.getAllDarijaNames(
          widget.plant.scientificName);
      final tamazight = await PlantTranslations.getAllTamazightNames(
          widget.plant.scientificName);
      if (mounted) {
        setState(() {
          _darijaNames = darija;
          _tamazightNames = tamazight;
          _isLoadingTranslations = false;
        });
        _fadeCtrl
          ..reset()
          ..forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _darijaNames = [widget.plant.darijaName];
          _tamazightNames = [widget.plant.tamazightName];
          _isLoadingTranslations = false;
        });
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: isError ? Colors.redAccent : AppTheme.primary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
    ));
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoCard(),
              const SizedBox(height: 20),
              _buildConfidenceBanner(),
              const SizedBox(height: 16),
              _buildInfoGrid(),
              const SizedBox(height: 16),
              _buildTranslationCard(
                language: 'Darija',
                script: 'بالدارجة',
                fontFamily: 'Arabic',
                names: _darijaNames,
                fallback: widget.plant.darijaName,
                accentColor: AppTheme.primary,
                accentBg: AppTheme.primarySurface,
              ),
              const SizedBox(height: 12),
              _buildTranslationCard(
                language: 'Tamazight',
                script: 'ⵜⴰⵎⴰⵣⵉⵖⵜ',
                fontFamily: 'Tifinagh',
                names: _tamazightNames,
                fallback: widget.plant.tamazightName,
                accentColor: AppTheme.badgeTranslation,
                accentBg: AppTheme.badgeTranslationBg,
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ── app bar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 60,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child:
                const Center(child: Text('🌿', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Text(AppLocalizations.of(context)!.result,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlantMapScreen(
                  plantName: widget.plant.name,
                  scientificName: widget.plant.scientificName,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_rounded, size: 15, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(AppLocalizations.of(context)!.distribution,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── photo card ─────────────────────────────────────────────────────────────
  Widget _buildPhotoCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Stack(
          children: [
            Image.file(widget.photo,
                height: 240, width: double.infinity, fit: BoxFit.cover),
            // gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // plant name overlay
            Positioned(
              bottom: 14,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plant.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    widget.plant.scientificName,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.82),
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

  // ── confidence banner ──────────────────────────────────────────────────────
  Widget _buildConfidenceBanner() {
    final pct = widget.plant.confidencePercentage;
    final color = pct >= 80
        ? AppTheme.primary
        : pct >= 50
            ? AppTheme.badgePlantOfDay
            : Colors.redAccent;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.confidence,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 7,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  // ── info grid ──────────────────────────────────────────────────────────────
  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.science_rounded,
            label: AppLocalizations.of(context)!.family,
            value: widget.plant.family,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.eco_rounded,
            label: AppLocalizations.of(context)!.scientificName,
            value: widget.plant.scientificName,
            italic: true,
          ),
        ),
      ],
    );
  }

  // ── translation card ───────────────────────────────────────────────────────
  Widget _buildTranslationCard({
    required String language,
    required String script,
    required String fontFamily,
    required List<String> names,
    required String fallback,
    required Color accentColor,
    required Color accentBg,
  }) {
    final displayNames =
        names.isNotEmpty ? names : (fallback.isNotEmpty ? [fallback] : []);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
                child:
                    Icon(Icons.translate_rounded, size: 17, color: accentColor),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: 0.3)),
                  Text(script,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: fontFamily,
                          color: AppTheme.textSecondary)),
                ],
              ),
              const Spacer(),
              // Refresh button
              GestureDetector(
                onTap: () {
                  setState(() => _isLoadingTranslations = true);
                  _loadTranslations();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.scaffoldBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  ),
                  child: Icon(Icons.refresh_rounded,
                      size: 16, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 12),
          // Names list
          if (_isLoadingTranslations)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: accentColor),
                ),
              ),
            )
          else if (displayNames.isEmpty)
            Text(AppLocalizations.of(context)!.noTranslationAvailable,
                style: TextStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary))
          else
            Column(
              children: displayNames.asMap().entries.map((entry) {
                final isLast = entry.key == displayNames.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: fontFamily,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, color: AppTheme.divider),
                  ],
                );
              }).toList(),
            ),
          if (displayNames.length > 1) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Text(
                '${displayNames.length} ${AppLocalizations.of(context)!.namesAvailable}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accentColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── action buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Propose translation
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TranslationProposalScreen(plant: widget.plant)),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: AppTheme.translationBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: AppTheme.translationBorder),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.contact_support_rounded,
                    size: 17, color: AppTheme.badgeTranslation),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.proposeTranslation,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.badgeTranslation,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Share with community — primary
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShareScreen(
                plant: widget.plant,
                photo: widget.photo,
                identificationId: widget.identificationId,
              ),
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.shareWithCommunity,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // New photo — secondary solid
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border:
                        Border.all(color: AppTheme.primary.withOpacity(0.35)),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_rounded,
                          size: 17, color: AppTheme.primary),
                      const SizedBox(width: 7),
                      Text(AppLocalizations.of(context)!.newPhoto,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // History — ghost
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.divider),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded,
                          size: 17, color: AppTheme.textSecondary),
                      const SizedBox(width: 7),
                      Text(AppLocalizations.of(context)!.history,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REUSABLE ATOMS
// ─────────────────────────────────────────────────────────────────────────────

/// Small info tile used in the 2-column grid
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.italic = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.primary),
              const SizedBox(width: 5),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
