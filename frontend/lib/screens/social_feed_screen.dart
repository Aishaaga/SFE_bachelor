import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../services/feed_service.dart';
import '../widgets/feed_post_card.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with AutomaticKeepAliveClientMixin {
  final FeedService _feedService = FeedService();
  final ScrollController _scrollController = ScrollController();

  List<FeedPost> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _selectedType;
  String? _error;

  @override
  bool get wantKeepAlive => true;

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
        type: _selectedType,
        page: _currentPage,
        limit: 20,
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
              print('Post data: $postJson');
              // Skip this post but continue with others
              continue;
            }
          }

          setState(() {
            if (refresh) {
              _posts = newPosts;
            } else {
              _posts.addAll(newPosts);
            }

            print('Pagination data: $pagination');
            final totalPages =
                int.tryParse(pagination['pages']?.toString() ?? '1') ?? 1;
            print('Total pages: $totalPages, current page: $_currentPage');
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to like post')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
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

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(result['message'] ?? 'Failed to flag post')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Network error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedType = value == 'all' ? null : value;
              });
              _refreshFeed();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Posts'),
              ),
              const PopupMenuItem(
                value: 'identification',
                child: Text('Identifications'),
              ),
              const PopupMenuItem(
                value: 'translation_suggestion',
                child: Text('Translation Suggestions'),
              ),
              const PopupMenuItem(
                value: 'plant_of_day',
                child: Text('Plant of the Day'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: _buildBody(),
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

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        try {
          if (index == _posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (index < 0 || index >= _posts.length) {
            print('Invalid index: $index, posts length: ${_posts.length}');
            return const SizedBox.shrink();
          }

          final post = _posts[index];
          return FeedPostCard(
            post: post,
            onLike: () => _likePost(post.id!),
            onFlag: () => _flagPost(post.id!),
          );
        } catch (e) {
          print('Error in itemBuilder at index $index: $e');
          return const SizedBox.shrink();
        }
      },
    );
  }
}
