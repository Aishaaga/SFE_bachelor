// lib/widgets/feed_post_card.dart
import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../services/feed_service.dart';
import '../utils/constants.dart';
import '../widgets/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  REUSABLE ATOMS
// ─────────────────────────────────────────────────────────────────────────────

/// Pill-shaped badge for post type / approval status
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
  });

  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + count action button used in the action row
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.count,
    required this.onTap,
    this.activeColor,
    this.isActive = false,
  });

  final IconData icon;
  final String count;
  final VoidCallback onTap;
  final Color? activeColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? (activeColor ?? AppTheme.primary) : AppTheme.actionIcon;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? (activeColor ?? AppTheme.primary).withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(
              count,
              style: AppTheme.actionCount.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Language tag + suggestion text row
class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.language, required this.text});
  final String language;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.translationTagBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          ),
          child: Text(
            language,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.translationText,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FEED POST CARD
// ─────────────────────────────────────────────────────────────────────────────
class FeedPostCard extends StatefulWidget {
  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onFlag;
  final Function(FeedPost)? onVoteUpdate;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onFlag,
    this.onVoteUpdate,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  final _darijaController = TextEditingController();
  final _tamazightController = TextEditingController();

  final FeedService _feedService = FeedService();

  bool _isSubmitting = false;
  late int _upvotes;
  late int _downvotes;
  late int _likes;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _upvotes = widget.post.upvotes;
    _downvotes = widget.post.downvotes;
    _likes = widget.post.likes;
  }

  @override
  void dispose() {
    _darijaController.dispose();
    _tamazightController.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  Color get _typeColor => _resolveTypeColor(widget.post.type);
  Color get _typeBg => _resolveTypeBg(widget.post.type);
  String get _typeLabel => _resolveTypeLabel(widget.post.type);

  static Color _resolveTypeColor(String type) {
    switch (type) {
      case 'identification':
        return AppTheme.badgeIdentification;
      case 'translation_suggestion':
        return AppTheme.badgeTranslation;
      case 'plant_of_day':
        return AppTheme.badgePlantOfDay;
      default:
        return AppTheme.textSecondary;
    }
  }

  static Color _resolveTypeBg(String type) {
    switch (type) {
      case 'identification':
        return AppTheme.badgeIdentificationBg;
      case 'translation_suggestion':
        return AppTheme.badgeTranslationBg;
      case 'plant_of_day':
        return AppTheme.badgePlantOfDayBg;
      default:
        return AppTheme.divider;
    }
  }

  static String _resolveTypeLabel(String type) {
    switch (type) {
      case 'identification':
        return 'Identification';
      case 'translation_suggestion':
        return 'Translation';
      case 'plant_of_day':
        return 'Plant of Day';
      default:
        return 'Post';
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(widget.post.createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (widget.post.type == 'identification' &&
                widget.post.imageUrl != null)
              _buildImage(),
            _buildContent(),
            _buildDivider(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  // ── header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.post.isAnonymous
                  ? Icons.person_outline_rounded
                  : Icons.person_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          // Name + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.post.isAnonymous
                            ? 'Anonymous'
                            : (widget.post.user?.email ?? 'Unknown'),
                        style: AppTheme.userHandle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.post.isApproved &&
                        widget.post.type == 'translation_suggestion') ...[
                      const SizedBox(width: 6),
                      _Pill(
                        label: 'Approved by admin',
                        color: AppTheme.approvedText,
                        bg: AppTheme.approvedBg,
                        icon: Icons.verified_rounded,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 11, color: AppTheme.textSecondary),
                    const SizedBox(width: 2),
                    Text(widget.post.location.displayText,
                        style: AppTheme.locationText),
                  ],
                ),
              ],
            ),
          ),
          // Type badge
          _Pill(label: _typeLabel, color: _typeColor, bg: _typeBg),
        ],
      ),
    );
  }

  // ── image ──────────────────────────────────────────────────────────────────
  Widget _buildImage() {
    final raw = widget.post.imageUrl!;
    final url = raw.startsWith('http')
        ? raw
        : '${Constants.apiUrl.replaceFirst('/api', '')}$raw';

    return Image.network(
      url,
      height: 210,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              height: 210,
              color: AppTheme.primarySurface,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
      errorBuilder: (_, __, ___) => Container(
        height: 210,
        color: AppTheme.primarySurface,
        child: const Icon(Icons.image_not_supported_rounded,
            size: 40, color: AppTheme.primary),
      ),
    );
  }

  // ── content ────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.post.plantName, style: AppTheme.plantName),
          const SizedBox(height: 3),
          Text(widget.post.scientificName, style: AppTheme.scientificName),
          if (widget.post.type == 'translation_suggestion') ...[
            const SizedBox(height: 12),
            _buildTranslationBox(),
          ],
          const SizedBox(height: 10),
          Text(_timeAgo(), style: AppTheme.timeAgo),
        ],
      ),
    );
  }

  Widget _buildTranslationBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.translationBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.translationBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate_rounded,
                  size: 14, color: AppTheme.translationText),
              const SizedBox(width: 5),
              Text(
                'Translation Suggestions',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.translationText,
                ),
              ),
            ],
          ),
          if (widget.post.suggestedDarija != null) ...[
            const SizedBox(height: 10),
            _SuggestionRow(
                language: 'Darija', text: widget.post.suggestedDarija!),
          ],
          if (widget.post.suggestedTamazight != null) ...[
            const SizedBox(height: 8),
            _SuggestionRow(
                language: 'Tamazight', text: widget.post.suggestedTamazight!),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(
        height: 1,
        thickness: 1,
        color: AppTheme.divider,
        indent: 14,
        endIndent: 14,
      );

  // ── actions ────────────────────────────────────────────────────────────────
  Widget _buildActions() {
    final isTranslation = widget.post.type == 'translation_suggestion';

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Column(
        children: [
          // "Propose translation" button for identification posts
          if (widget.post.type == 'identification') ...[
            _buildProposeButton(),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              // Like
              _ActionButton(
                icon: _isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                count: _likes.toString(),
                onTap: _handleLike,
                activeColor: AppTheme.likeActive,
                isActive: _isLiked,
              ),
              const SizedBox(width: 2),
              // Comments
              _ActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                count: widget.post.commentCount.toString(),
                onTap: () {},
              ),
              const Spacer(),
              // Upvote / Downvote (translation only, not approved)
              if (isTranslation && !widget.post.isApproved) ...[
                _ActionButton(
                  icon: Icons.thumb_up_rounded,
                  count: _upvotes.toString(),
                  onTap: () => _handleVote('upvote'),
                  activeColor: AppTheme.upvoteColor,
                ),
                const SizedBox(width: 2),
                _ActionButton(
                  icon: Icons.thumb_down_rounded,
                  count: _downvotes.toString(),
                  onTap: () => _handleVote('downvote'),
                  activeColor: AppTheme.downvoteColor,
                ),
                const SizedBox(width: 4),
              ],
              // Flag
              GestureDetector(
                onTap: widget.onFlag,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.flag_outlined,
                      size: 20, color: AppTheme.actionIcon),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProposeButton() {
    return GestureDetector(
      onTap: () => _showTranslationDialog(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: AppTheme.badgeTranslationBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppTheme.translationBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.translate_rounded,
                size: 16, color: AppTheme.badgeTranslation),
            SizedBox(width: 7),
            Text(
              'Proposer traduction',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.badgeTranslation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── translation dialog ─────────────────────────────────────────────────────
  void _showTranslationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proposer traduction',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(widget.post.plantName,
                style: AppTheme.plantName
                    .copyWith(fontSize: 14, color: AppTheme.primary)),
            Text(widget.post.scientificName, style: AppTheme.scientificName),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _darijaController,
                decoration: InputDecoration(
                  labelText: 'Darija',
                  hintText: 'Entrez la traduction en darija…',
                  prefixIcon: const Icon(Icons.translate_rounded,
                      color: AppTheme.badgeTranslation),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _tamazightController,
                decoration: InputDecoration(
                  labelText: 'Tamazight',
                  hintText: 'Entrez la traduction en tamazight…',
                  prefixIcon:
                      Icon(Icons.translate_rounded, color: AppTheme.primary),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Text(
                'Au moins une traduction est requise.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _darijaController.clear();
              _tamazightController.clear();
            },
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: _isSubmitting ? null : () => _submitTranslation(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Proposer'),
          ),
        ],
      ),
    );
  }

  // ── async actions ──────────────────────────────────────────────────────────
  Future<void> _submitTranslation(BuildContext ctx) async {
    final darija = _darijaController.text.trim();
    final tamazight = _tamazightController.text.trim();

    if (darija.isEmpty && tamazight.isEmpty) {
      _showSnack('Veuillez fournir au moins une traduction',
          backgroundColor: Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String plantId = widget.post.plantId;
      if (plantId.isEmpty && widget.post.identificationId != null) {
        plantId = widget.post.identificationId!;
      }
      if (plantId.isEmpty) throw Exception('Plant ID is required');

      final result = await _feedService.shareToFeed(
        type: 'translation_suggestion',
        plantId: plantId,
        plantName: widget.post.plantName,
        scientificName: widget.post.scientificName,
        suggestedDarija: darija.isNotEmpty ? darija : null,
        suggestedTamazight: tamazight.isNotEmpty ? tamazight : null,
        isAnonymous: false,
        location: {'level': 'country', 'country': 'Morocco'},
      );

      if (mounted) {
        Navigator.pop(ctx);
        _darijaController.clear();
        _tamazightController.clear();
        _showSnack(
          result['success']
              ? 'Traduction proposée avec succès!'
              : (result['message'] ?? 'Erreur'),
          backgroundColor:
              result['success'] ? AppTheme.primary : Colors.redAccent,
        );
      }
    } catch (e) {
      if (mounted) _showSnack('Erreur: $e', backgroundColor: Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleVote(String voteType) async {
    try {
      final result = await _feedService.voteOnTranslation(
        postId: widget.post.id!,
        voteType: voteType,
      );
      if (result['success']) {
        _showSnack(result['message'] ?? 'Vote recorded',
            backgroundColor: AppTheme.primary, duration: 1);
        if (result['voteCounts'] != null) {
          setState(() {
            _upvotes = result['voteCounts']['upvotes'] ?? _upvotes;
            _downvotes = result['voteCounts']['downvotes'] ?? _downvotes;
          });
          widget.onVoteUpdate?.call(
            widget.post.copyWith(upvotes: _upvotes, downvotes: _downvotes),
          );
        }
      } else {
        _showSnack(result['message'] ?? 'Error voting',
            backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', backgroundColor: Colors.redAccent);
    }
  }

  Future<void> _handleLike() async {
    try {
      final result = await _feedService.likePost(widget.post.id!);
      if (result['success']) {
        setState(() {
          _likes = result['likes'] ?? _likes;
          _isLiked = result['liked'] ?? !_isLiked;
        });
        widget.onLike();
      } else {
        _showSnack(result['message'] ?? 'Error liking post',
            backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', backgroundColor: Colors.redAccent);
    }
  }

  void _showSnack(
    String message, {
    Color backgroundColor = AppTheme.primary,
    int duration = 2,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }
}
