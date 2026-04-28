import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ShareFromHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> identification;
  final String imageUrl;

  const ShareFromHistoryScreen({
    super.key,
    required this.identification,
    required this.imageUrl,
  });

  @override
  State<ShareFromHistoryScreen> createState() => _ShareFromHistoryScreenState();
}

class _ShareFromHistoryScreenState extends State<ShareFromHistoryScreen> {
  final AuthService _authService = AuthService();
  String _postAs = 'Ahmed';
  String _location = 'Morocco only';
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final email = await _authService.getCurrentUserEmail();
    if (mounted && email != null) {
      setState(() {
        _userEmail = email;
        _postAs = email; // Set default to user email
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Discovery'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  112, // Account for app bar and padding
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with leaf icon
                  Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Share your discovery?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Plant photo
                  Center(
                    child: Card(
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(Icons.eco,
                                  size: 50, color: Colors.grey),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.green),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Post as section
                  Text(
                    'Post as:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: Text(_userEmail != null ? _userEmail! : 'User'),
                    value: _userEmail != null ? _userEmail! : 'User',
                    groupValue: _postAs,
                    onChanged: (value) {
                      setState(() {
                        _postAs = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile<String>(
                    title: const Text('Anonymous'),
                    value: 'Anonymous',
                    groupValue: _postAs,
                    onChanged: (value) {
                      setState(() {
                        _postAs = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(height: 16),

                  // Location section
                  Text(
                    'Location:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: const Text('Morocco only'),
                    value: 'Morocco only',
                    groupValue: _location,
                    onChanged: (value) {
                      setState(() {
                        _location = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile<String>(
                    title: const Text('Add city (Casablanca)'),
                    value: 'Casablanca',
                    groupValue: _location,
                    onChanged: (value) {
                      setState(() {
                        _location = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(height: 8),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your country is always shown for context',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _shareDiscovery,
                          child: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _shareDiscovery() {
    // Show success message
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Discovery Posted!'),
          ],
        ),
        content: Text(
          'Your discovery has been posted ${_postAs == 'Anonymous' ? 'anonymously' : 'as $_postAs'} and will be visible to the community.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to detail screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
