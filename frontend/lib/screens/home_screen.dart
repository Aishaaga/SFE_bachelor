import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../services/feed_service.dart';
import '../widgets/feed_post_card.dart';
import 'camera_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

// ─────────────────────────────────────────────
//  THEME HELPER  (put in lib/theme/app_theme.dart if you prefer)
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF2E7D32); // deep green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color surface = Color(0xFFF6F8F5);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color navBg = Colors.white;

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: surface,
        ),
        scaffoldBackgroundColor: surface,
        fontFamily: 'SF Pro Display', // falls back to system sans-serif
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
      );
}

// ─────────────────────────────────────────────
//  FLOATING BOTTOM NAV BAR  (reusable widget)
// ─────────────────────────────────────────────
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Feed'),
    _NavItem(icon: Icons.camera_alt_rounded, label: 'Camera'),
    _NavItem(icon: Icons.notifications_rounded, label: 'Notifications'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      // lifts the bar off the screen edge — creates the "floating" look
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppTheme.navBg,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final isActive = i == currentIndex;
            return _NavTile(
              icon: item.icon,
              label: item.label,
              isActive: isActive,
              onTap: () => onTap(i),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withOpacity(0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(isActive),
                size: 22,
                color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                letterSpacing: 0.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  APP HEADER  (reusable)
// ─────────────────────────────────────────────
class SfeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SfeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(width: 12),
          const Text(
            'FLORAI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN  (drop-in replacement)
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FeedService _feedService = FeedService();
  final ScrollController _scrollController = ScrollController();

  List<FeedPost> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFeedPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── scroll pagination ──────────────────────
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) _loadMorePosts();
    }
  }

  // ── data loading ───────────────────────────
  Future<void> _loadFeedPosts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _hasMore = true;
        _posts.clear();
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _feedService.getFeedPosts(
        page: _currentPage,
        limit: 10,
      );

      if (mounted) {
        if (result['success']) {
          final List<dynamic> postsData = result['posts'];
          final pagination = result['pagination'];

          final newPosts = <FeedPost>[];
          for (final postJson in postsData) {
            try {
              newPosts.add(FeedPost.fromJson(postJson));
            } catch (e) {
              debugPrint('Error parsing post: $e');
            }
          }

          setState(() {
            if (refresh) {
              _posts = newPosts;
            } else {
              _posts.addAll(newPosts);
            }
            final totalPages =
                int.tryParse(pagination['pages']?.toString() ?? '1') ?? 1;
            _hasMore = _currentPage < totalPages;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = result['message'] ?? 'Failed to load feed posts';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Network error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await _loadFeedPosts();
  }

  Future<void> _refreshFeed() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadFeedPosts(refresh: true);
  }

  Future<void> _likePost(String postId) async {
    try {
      final result = await _feedService.likePost(postId);
      if (result['success']) {
        setState(() {
          final idx = _posts.indexWhere((p) => p.id == postId);
          if (idx != -1) {
            _posts[idx] = _posts[idx].copyWith(likes: result['likes']);
          }
        });
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }

  Future<void> _flagPost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Flag Post'),
        content: const Text('Are you sure you want to flag this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Flag'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _feedService.flagPost(postId);
        if (result['success']) {
          setState(() => _posts.removeWhere((p) => p.id == postId));
        }
      } catch (e) {
        debugPrint('Error flagging post: $e');
      }
    }
  }

  void _updateCommentCount(FeedPost updatedPost) {
    setState(() {
      final idx = _posts.indexWhere((p) => p.id == updatedPost.id);
      if (idx != -1) {
        _posts[idx] = updatedPost;
      }
    });
  }

  // ── screens ────────────────────────────────
  List<Widget> _getScreens() => [
        _buildFeedScreen(),
        const CameraScreen(),
        const NotificationsScreen(),
        const ProfileScreen(),
      ];

  // ── feed screen ────────────────────────────
  Widget _buildFeedScreen() {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: const SfeAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_error != null && _posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 20),
              Text(
                _error!,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _refreshFeed,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco_rounded,
                  size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No posts yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to share a discovery!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _refreshFeed,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }
          final post = _posts[index];
          return FeedPostCard(
            post: post,
            onLike: () => _likePost(post.id!),
            onFlag: () => _flagPost(post.id!),
            onCommentUpdate: _updateCommentCount,
          );
        },
      ),
    );
  }

  // ── root build ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screens = _getScreens();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      // extendBody lets the list scroll behind the floating nav bar
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // ▼▼▼  FLOATING NAV BAR — replaces the old BottomNavigationBar  ▼▼▼
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
