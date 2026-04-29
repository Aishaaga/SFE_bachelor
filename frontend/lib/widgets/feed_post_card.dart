import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../services/feed_service.dart';
import '../utils/constants.dart';

class FeedPostCard extends StatefulWidget {
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
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  final _darijaController = TextEditingController();
  final _tamazightController = TextEditingController();
  bool _isSubmitting = false;
  final FeedService _feedService = FeedService();

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
          if (widget.post.type == 'identification' &&
              widget.post.imageUrl != null)
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
            child: widget.post.isAnonymous
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
                  widget.post.isAnonymous
                      ? 'Anonymous'
                      : (widget.post.user?.email ?? 'Unknown'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.post.location.displayText,
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
    final imageUrl = widget.post.imageUrl;
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
            widget.post.plantName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.post.scientificName,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
          if (widget.post.type == 'translation_suggestion') ...[
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
          if (widget.post.suggestedDarija != null) ...[
            const SizedBox(height: 8),
            _buildSuggestion('Darija', widget.post.suggestedDarija!),
          ],
          if (widget.post.suggestedTamazight != null) ...[
            const SizedBox(height: 8),
            _buildSuggestion('Tamazight', widget.post.suggestedTamazight!),
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
      child: Column(
        children: [
          // Translation suggestion button for identification posts
          if (widget.post.type == 'identification')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton.icon(
                onPressed: () => _showTranslationDialog(context),
                icon: Icon(
                  Icons.translate,
                  size: 18,
                  color: Colors.blue[700],
                ),
                label: Text(
                  'Proposer traduction',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                  elevation: 0,
                  side: BorderSide(color: Colors.blue[200]!),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          // Regular action buttons
          Row(
            children: [
              IconButton(
                onPressed: widget.onLike,
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
                      widget.post.likes.toString(),
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
                      widget.post.commentCount.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (widget.post.type == 'translation_suggestion') ...[
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      widget.post.upvotes.toString(),
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
                      widget.post.downvotes.toString(),
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
                onPressed: widget.onFlag,
                icon: Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.post.type) {
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
    switch (widget.post.type) {
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
    final difference = now.difference(widget.post.createdAt);

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

  void _showTranslationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Proposer traduction pour ${widget.post.plantName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.scientificName,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _darijaController,
                decoration: InputDecoration(
                  labelText: 'Traduction Darija',
                  hintText: 'Entrez la traduction en darija...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.translate, color: Colors.blue),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tamazightController,
                decoration: InputDecoration(
                  labelText: 'Traduction Tamazight',
                  hintText: 'Entrez la traduction en tamazight...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.translate, color: Colors.green),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Text(
                'Au moins une traduction est requise',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _darijaController.clear();
              _tamazightController.clear();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () => _submitTranslation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Proposer'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTranslation(BuildContext context) async {
    final darija = _darijaController.text.trim();
    final tamazight = _tamazightController.text.trim();

    if (darija.isEmpty && tamazight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez fournir au moins une traduction'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Debug the plant information
      print('DEBUG: FeedPostCard - Creating translation suggestion:');
      print('  post.plantId: ${widget.post.plantId}');
      print('  post.identificationId: ${widget.post.identificationId}');
      print('  post.plantName: ${widget.post.plantName}');
      print('  post.scientificName: ${widget.post.scientificName}');

      // Ensure we have a valid plantId
      String plantId = widget.post.plantId;
      if (plantId.isEmpty && widget.post.identificationId != null) {
        // Use identificationId as fallback for plantId
        plantId = widget.post.identificationId!;
        print('  Using identificationId as plantId: $plantId');
      }

      if (plantId.isEmpty) {
        throw Exception('Plant ID is required for translation suggestions');
      }

      // Create a translation suggestion feed post
      final result = await _feedService.shareToFeed(
        type: 'translation_suggestion',
        plantId: plantId,
        plantName: widget.post.plantName,
        scientificName: widget.post.scientificName,
        suggestedDarija: darija.isNotEmpty ? darija : null,
        suggestedTamazight: tamazight.isNotEmpty ? tamazight : null,
        isAnonymous: false,
        location: {
          'level': 'country',
          'country': 'Morocco',
        },
      );

      if (mounted) {
        Navigator.pop(context);
        _darijaController.clear();
        _tamazightController.clear();

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Traduction proposée avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result['message'] ?? 'Erreur lors de la proposition'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _darijaController.dispose();
    _tamazightController.dispose();
    super.dispose();
  }
}
