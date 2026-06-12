import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../models/comment.dart';
import '../services/feed_service.dart';
import '../services/auth_service.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/app_theme.dart';

class CommentsScreen extends StatefulWidget {
  final FeedPost post;

  const CommentsScreen({
    super.key,
    required this.post,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final FeedService _feedService = FeedService();
  final AuthService _authService = AuthService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isAnonymous = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  int _commentCount = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.post.commentCount;
    _loadCurrentUserId();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await _authService.getCurrentUserId();
    if (mounted) {
      setState(() {
        _currentUserId = userId;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) _loadMoreComments();
    }
  }

  Future<void> _loadComments({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _hasMore = true;
        _comments.clear();
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _feedService.getComments(
        widget.post.id!,
        page: _currentPage,
        limit: 20,
      );

      if (mounted) {
        if (result['success']) {
          final newComments = result['comments'] as List<Comment>;
          final pagination = result['pagination'];

          setState(() {
            if (refresh) {
              _comments = newComments;
            } else {
              _comments.addAll(newComments);
            }
            final totalPages =
                int.tryParse(pagination['pages']?.toString() ?? '1') ?? 1;
            _hasMore = _currentPage < totalPages;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = result['message'] ?? 'Failed to load comments';
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

  Future<void> _loadMoreComments() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await _loadComments();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _feedService.addComment(
        widget.post.id!,
        content,
        isAnonymous: _isAnonymous,
      );

      if (mounted) {
        if (result['success']) {
          _commentController.clear();
          setState(() {
            _comments.insert(0, result['comment']);
            _commentCount = result['commentCount'];
          });
          _showSnack('Comment added successfully');
        } else {
          _showSnack(result['message'] ?? 'Error adding comment',
              backgroundColor: Colors.redAccent);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: $e', backgroundColor: Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await _feedService.deleteComment(commentId);
        if (mounted) {
          if (result['success']) {
            setState(() {
              _comments.removeWhere((c) => c.id == commentId);
              _commentCount = result['commentCount'];
            });
            _showSnack('Comment deleted');
          } else {
            _showSnack(result['message'] ?? 'Error deleting comment',
                backgroundColor: Colors.redAccent);
          }
        }
      } catch (e) {
        if (mounted) {
          _showSnack('Error: $e', backgroundColor: Colors.redAccent);
        }
      }
    }
  }

  void _showSnack(
    String message, {
    Color backgroundColor = AppTheme.primary,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final updatedPost = widget.post.copyWith(commentCount: _commentCount);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context, updatedPost),
        ),
        title: const Text(
          'Comments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Post preview at the top
          Container(
            color: Colors.white,
            child: FeedPostCard(
              post: updatedPost,
              onLike: () {},
              onFlag: () {},
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppTheme.divider),
          // Comments list
          Expanded(
            child: _buildCommentsList(),
          ),
          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_isLoading && _comments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_error != null && _comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.grey[300]),
              const SizedBox(height: 20),
              Text(
                _error!,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _loadComments(refresh: true),
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

    if (_comments.isEmpty) {
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
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No comments yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to comment!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => _loadComments(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _comments.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _comments.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }
          final comment = _comments[index];
          return _CommentTile(
            comment: comment,
            onDelete: () => _deleteComment(comment.id!),
            currentUserId: _currentUserId,
          );
        },
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Anonymous toggle
          Row(
            children: [
              Checkbox(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Text(
                'Comment anonymously',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Text input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: AppTheme.scaffoldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              const SizedBox(width: 12),
              _isSubmitting
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primary),
                    )
                  : IconButton(
                      onPressed: _submitComment,
                      icon: const Icon(Icons.send_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback onDelete;
  final String? currentUserId;

  const _CommentTile({
    required this.comment,
    required this.onDelete,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.isAnonymous
                          ? 'Anonymous #${comment.anonymousId ?? '??'}'
                          : (comment.user?.displayName ?? 'Unknown'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (comment.isEdited) ...[
                      const SizedBox(width: 4),
                      Text(
                        '· edited',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Delete button (only for comment author)
          if (!comment.isAnonymous &&
              currentUserId != null &&
              currentUserId == comment.userId)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.more_horiz_rounded),
              color: Colors.grey[400],
              iconSize: 20,
              padding: const EdgeInsets.all(4),
            ),
        ],
      ),
    );
  }
}
