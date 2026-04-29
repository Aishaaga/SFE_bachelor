import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class ShareScreen extends StatefulWidget {
  final Plant plant;
  final File photo;
  final String? identificationId;

  const ShareScreen({
    super.key,
    required this.plant,
    required this.photo,
    this.identificationId,
  });

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final AuthService _authService = AuthService();
  String _postAs = 'Ahmed';
  String _location = 'Morocco only';
  String? _userEmail;
  String? _detectedCity;
  bool _isLoadingLocation = false;
  bool _locationPermissionDenied = false;

  // Location levels
  final List<String> _locationLevels = ['Morocco only', 'City', 'None'];
  final List<String> _moroccanCities = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fez',
    'Tangier',
    'Agadir',
    'Meknes'
  ];

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

  Future<void> _detectLocation() async {
    print('DEBUG: _detectLocation called');
    setState(() {
      _isLoadingLocation = true;
      _locationPermissionDenied = false;
    });

    try {
      print('DEBUG: Calling LocationService.getCurrentCity...');
      final city = await LocationService.getCurrentCity();
      print('DEBUG: LocationService returned: $city');
      if (mounted) {
        setState(() {
          _detectedCity = city;
          _isLoadingLocation = false;
          if (city != null) {
            _location = city;
          }
        });
      }
    } catch (e) {
      print('DEBUG: Exception in _detectLocation: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationPermissionDenied = true;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    await LocationService.openAppSettings();
  }

  String _getLocationTitle(String level) {
    switch (level) {
      case 'Morocco only':
        return 'Morocco only';
      case 'City':
        return 'City level';
      case 'None':
        return 'No location';
      default:
        return level;
    }
  }

  String _getLocationSubtitle(String level) {
    switch (level) {
      case 'Morocco only':
        return 'Show only country level';
      case 'City':
        return 'Show your specific city';
      case 'None':
        return 'Hide location completely';
      default:
        return '';
    }
  }

  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select City'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _moroccanCities.length,
            itemBuilder: (context, index) {
              final city = _moroccanCities[index];
              return ListTile(
                title: Text(city),
                trailing: _location == city
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _location = city;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
                        child: Image.file(
                          widget.photo,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
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
                  // Location level selection
                  ..._locationLevels.map((level) => RadioListTile<String>(
                        title: Text(_getLocationTitle(level)),
                        subtitle: Text(_getLocationSubtitle(level)),
                        value: level,
                        groupValue: _location,
                        onChanged: (value) {
                          setState(() {
                            _location = value!;
                            if (value == 'City' && _detectedCity == null) {
                              _detectLocation();
                            }
                          });
                        },
                        activeColor: Colors.green,
                      )),
                  // City selection and detection
                  if (_location == 'City') ...[
                    if (_isLoadingLocation)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircularProgressIndicator(color: Colors.green),
                            SizedBox(width: 16),
                            Text('Detecting your city...'),
                          ],
                        ),
                      )
                    else if (_locationPermissionDenied)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location permission denied',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _openSettings,
                              child: const Text('Open Settings'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_detectedCity != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Detected city: $_detectedCity',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showCitySelectionDialog(),
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
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
    final locationText = _getLocationDisplayText();

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your discovery has been posted ${_postAs == 'Anonymous' ? 'anonymously' : 'as $_postAs'} and will be visible to the community.',
            ),
            const SizedBox(height: 8),
            Text(
              'Location: $locationText',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to result screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getLocationDisplayText() {
    switch (_location) {
      case 'Morocco only':
        return 'Morocco only';
      case 'None':
        return 'No location';
      default:
        // If it's a detected city (not in predefined list)
        if (!_moroccanCities.contains(_location) && _detectedCity != null) {
          return '$_detectedCity (detected)';
        }
        // If it's a manually selected city
        if (_moroccanCities.contains(_location)) {
          return _location;
        }
        // Fallback
        return _location;
    }
  }
}
