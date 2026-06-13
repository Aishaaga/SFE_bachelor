// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_theme.dart';
import 'history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locController = TextEditingController();

  final _profileService = ProfileService();
  final _authService = AuthService();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadProfile();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _locController.dispose();
    super.dispose();
  }

  // ── data ───────────────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final result = await _profileService.getProfile();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _user = result['user'];
          _nameController.text = _user?.name ?? '';
          _bioController.text = _user?.bio ?? '';
          _locController.text = _user?.location ?? '';
        }
      });
      if (result['success'] == true) {
        _fadeCtrl
          ..reset()
          ..forward();
      } else {
        _showSnack(result['message'] ?? 'Erreur de chargement', isError: true);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final result = await _profileService.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      location: _locController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _isSaving = false;
        if (result['success'] == true) {
          _user = result['user'];
          _isEditing = false;
        }
      });
      _showSnack(result['message'] ?? 'Profil mis à jour',
          isError: result['success'] != true);
    }
  }

  void _cancelEdit() => setState(() {
        _isEditing = false;
        _nameController.text = _user?.name ?? '';
        _bioController.text = _user?.bio ?? '';
        _locController.text = _user?.location ?? '';
      });

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _user == null
              ? _buildLoadError()
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        children: [
                          _buildHeroHeader(),
                          const SizedBox(height: 20),
                          _pad(_buildInfoCard()),
                          const SizedBox(height: 12),
                          _pad(_buildHistoryCard()),
                          const SizedBox(height: 12),
                          _pad(_buildStatsCard()),
                          const SizedBox(height: 24),
                          _pad(_buildLogoutButton()),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _pad(Widget w) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: w);

  // ── app bar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primary,
      elevation: 0,
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo_sfe.png',
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
      actions: [
        if (_user != null && !_isEditing)
          _AppBarPill(
            icon: Icons.edit_rounded,
            label: 'Modifier',
            onTap: () => setState(() => _isEditing = true),
          ),
        if (_isEditing) ...[
          _AppBarPill(
            icon: Icons.check_rounded,
            label: 'Sauver',
            onTap: _isSaving ? null : _updateProfile,
            loading: _isSaving,
          ),
          _AppBarPill(icon: Icons.close_rounded, onTap: _cancelEdit),
        ],
        const SizedBox(width: 4),
      ],
    );
  }

  // ── hero header ────────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    final initial = (_user!.name.isNotEmpty ? _user!.name : _user!.email)
        .substring(0, 1)
        .toUpperCase();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXl),
          bottomRight: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
            ),
            child: _user!.profileImage.isNotEmpty
                ? ClipOval(
                    child: Image.network(_user!.profileImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarText(initial)))
                : _avatarText(initial),
          ),
          const SizedBox(height: 14),
          Text(
            _user!.name.isNotEmpty ? _user!.name : _user!.email,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _user!.email,
            style:
                TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.72)),
          ),
          if (_user!.role == 'admin') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.badgePlantOfDay,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Admin',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarText(String initial) => Center(
        child: Text(initial,
            style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
      );

  // ── info card ──────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    final isEmpty = !_isEditing &&
        _user!.name.isEmpty &&
        _user!.location.isEmpty &&
        _user!.bio.isEmpty;

    return _SectionCard(
      title: 'Informations personnelles',
      icon: Icons.person_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing) ...[
            _StyledField(
              controller: _nameController,
              label: 'Nom',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v?.trim().length ?? 0) > 50 ? 'Max 50 caractères' : null,
            ),
            const SizedBox(height: 12),
            _StyledField(
              controller: _locController,
              label: 'Localisation',
              icon: Icons.location_on_outlined,
              validator: (v) =>
                  (v?.trim().length ?? 0) > 100 ? 'Max 100 caractères' : null,
            ),
            const SizedBox(height: 12),
            _StyledField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.info_outline_rounded,
              maxLines: 3,
              validator: (v) =>
                  (v?.trim().length ?? 0) > 500 ? 'Max 500 caractères' : null,
            ),
          ] else if (isEmpty)
            Text(
              'Aucune information personnelle ajoutée.',
              style: const TextStyle(
                  fontSize: 13.5,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondary),
            )
          else ...[
            if (_user!.name.isNotEmpty)
              _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nom',
                  value: _user!.name),
            if (_user!.location.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Localisation',
                  value: _user!.location),
            ],
            if (_user!.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Bio',
                  value: _user!.bio),
            ],
          ],
        ],
      ),
    );
  }

  // ── history card ───────────────────────────────────────────────────────────
  Widget _buildHistoryCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(Icons.history_rounded,
                  color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mon historique',
                      style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Toutes vos identifications',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }

  // ── stats card ─────────────────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return _SectionCard(
      title: 'Statistiques',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          _StatRow(
              icon: Icons.post_add_rounded,
              label: 'Contributions',
              value: '${_user!.contributionsCount}'),
          const _Divider(),
          _StatRow(
              icon: Icons.search_rounded,
              label: 'Identifications',
              value: '${_user!.identificationsCount}'),
          const _Divider(),
          _StatRow(
              icon: Icons.translate_rounded,
              label: 'Suggestions',
              value: '${_user!.translationSuggestionsCount}'),
          const _Divider(),
          _StatRow(
              icon: Icons.calendar_today_rounded,
              label: 'Membre depuis',
              value: DateFormat('dd MMM yyyy').format(_user!.createdAt),
              isDate: true),
        ],
      ),
    );
  }

  // ── logout ─────────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
              color: AppTheme.downvoteColor.withOpacity(0.35), width: 1),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 18, color: AppTheme.downvoteColor),
            const SizedBox(width: 8),
            Text('Déconnexion',
                style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.downvoteColor)),
          ],
        ),
      ),
    );
  }

  // ── load error ─────────────────────────────────────────────────────────────
  Widget _buildLoadError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_off_rounded,
                size: 36, color: Colors.redAccent),
          ),
          const SizedBox(height: 20),
          const Text('Erreur lors du chargement',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loadProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primary.withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Text('Réessayer',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REUSABLE ATOMS
// ─────────────────────────────────────────────────────────────────────────────

/// Frosted pill button in the app bar
class _AppBarPill extends StatelessWidget {
  const _AppBarPill(
      {required this.icon, this.label, this.onTap, this.loading = false});

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: label != null ? 10 : 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
          child: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: Colors.white),
                    if (label != null) ...[
                      const SizedBox(width: 4),
                      Text(label!,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Labelled section card used for info and stats blocks
class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Icon + label + value read-only info row
class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primarySurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          ),
          child: Icon(icon, size: 15, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.3)),
            const SizedBox(height: 1),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 255),
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Editable form field using AppTheme styling
class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
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
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

/// Stat row: icon square + label + bold value
class _StatRow extends StatelessWidget {
  const _StatRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.isDate = false});

  final IconData icon;
  final String label;
  final String value;
  final bool isDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: isDate ? 12.5 : 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  letterSpacing: -0.3)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppTheme.divider);
}
