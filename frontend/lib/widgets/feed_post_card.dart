import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../utils/constants.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onFlag;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onFlag,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (post.type == 'identification' && post.imageUrl != null)
            _buildImage(),
          _buildContent(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green.shade100,
            child: post.isAnonymous
                ? Icon(
                    Icons.person_outline,
                    color: Colors.green.shade700,
                  )
                : Icon(
                    Icons.person,
                    color: Colors.green.shade700,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.isAnonymous
                      ? 'Anonymous'
                      : (post.user?.email ?? 'Unknown'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  post.location.displayText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getTypeDisplayText(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _getTypeColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Construct full URL from relative path
    final imageUrl = post.imageUrl;
    if (imageUrl == null) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 40,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    String fullImageUrl = imageUrl;
    if (!fullImageUrl.startsWith('http')) {
      // Remove the /api part from Constants.apiUrl to get the base URL
      final baseUrl = Constants.apiUrl.replaceFirst('/api', '');
      fullImageUrl = '$baseUrl$imageUrl';
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      child: Image.network(
        fullImageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Image loading error: $error');
          print('Image URL: $fullImageUrl');
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.plantName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post.scientificName,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
          if (post.type == 'translation_suggestion') ...[
            const SizedBox(height: 12),
            _buildTranslationSuggestions(),
          ],
          const SizedBox(height: 8),
          Text(
            _getTimeAgo(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationSuggestions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Translation Suggestions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          if (post.suggestedDarija != null) ...[
            const SizedBox(height: 8),
            _buildSuggestion('Darija', post.suggestedDarija!),
          ],
          if (post.suggestedTamazight != null) ...[
            const SizedBox(height: 8),
            _buildSuggestion('Tamazight', post.suggestedTamazight!),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestion(String language, String suggestion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            language,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            suggestion,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onLike,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  post.likes.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implement comments
            },
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  post.commentCount.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (post.type == 'translation_suggestion') ...[
            Row(
              children: [
                Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 2),
                Text(
                  post.upvotes.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Icon(
                  Icons.thumb_down_outlined,
                  size: 16,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 2),
                Text(
                  post.downvotes.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            onPressed: onFlag,
            icon: Icon(
              Icons.flag_outlined,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (post.type) {
      case 'identification':
        return Colors.green;
      case 'translation_suggestion':
        return Colors.blue;
      case 'plant_of_day':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplayText() {
    switch (post.type) {
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

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(post.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
