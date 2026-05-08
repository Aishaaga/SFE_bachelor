import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../services/feed_service.dart';
import '../widgets/feed_post_card.dart';
import 'camera_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMorePosts();
      }
    }
  }

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
              print('Error parsing post: $e');
              continue;
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
          final postIndex = _posts.indexWhere((post) => post.id == postId);
          if (postIndex != -1) {
            final post = _posts[postIndex];
            _posts[postIndex] = post.copyWith(likes: result['likes']);
          }
        });
      }
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  Future<void> _flagPost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flag Post'),
        content: const Text('Are you sure you want to flag this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Flag'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _feedService.flagPost(postId);
        if (result['success']) {
          setState(() {
            _posts.removeWhere((post) => post.id == postId);
          });
        }
      } catch (e) {
        print('Error flagging post: $e');
      }
    }
  }

  List<Widget> _getScreens() {
    return [
      _buildFeedScreen(),
      const CameraScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
  }

  Widget _buildFeedScreen() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            '🌿 SFE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshFeed,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share a discovery!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final post = _posts[index];
          return FeedPostCard(
            post: post,
            onLike: () => _likePost(post.id!),
            onFlag: () => _flagPost(post.id!),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getScreens();

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
