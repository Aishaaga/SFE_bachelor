import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/feed_service.dart';
import '../services/profile_service.dart';
import '../data/plant_translations.dart';
import '../widgets/app_theme.dart';

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
  final ProfileService _profileService = ProfileService();
  String _postAs = 'Ahmed';
  String _location = 'Morocco only';
  String? _username;
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
    final result = await _profileService.getProfile();
    if (mounted && result['success'] == true) {
      final user = result['user'];
      setState(() {
        _username = user.username;
        _postAs = user.username; // Set default to user username
      });
    }
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationPermissionDenied = false;
    });

    try {
      final city = await LocationService.getCurrentCity();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Select City',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _moroccanCities.length,
            itemBuilder: (context, index) {
              final city = _moroccanCities[index];
              return ListTile(
                title: Text(
                  city,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: _location == city
                    ? Icon(Icons.check, color: AppTheme.primary)
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
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Share Discovery',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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

                  // Plant photo
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Image.network(
                          widget.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 220,
                              width: double.infinity,
                              color: AppTheme.primarySurface,
                              child: Icon(Icons.eco,
                                  size: 50, color: AppTheme.primary),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 220,
                              width: double.infinity,
                              color: AppTheme.primarySurface,
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.primary),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(
                            _username != null ? _username! : 'User',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          value: _username != null ? _username! : 'User',
                          groupValue: _postAs,
                          onChanged: (value) {
                            setState(() {
                              _postAs = value!;
                            });
                          },
                          activeColor: AppTheme.primary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 1,
                          ),
                        ),
                        Divider(height: 1, color: AppTheme.divider),
                        RadioListTile<String>(
                          title: const Text(
                            'Anonymous',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: 'Anonymous',
                          groupValue: _postAs,
                          onChanged: (value) {
                            setState(() {
                              _postAs = value!;
                            });
                          },
                          activeColor: AppTheme.primary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location section
                  Text(
                    'Location:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        ..._locationLevels.map((level) {
                          final isLast = level == _locationLevels.last;
                          return Column(
                            children: [
                              RadioListTile<String>(
                                title: Text(
                                  _getLocationTitle(level),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  _getLocationSubtitle(level),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                value: level,
                                groupValue: _location,
                                onChanged: (value) {
                                  setState(() {
                                    _location = value!;
                                    if (value == 'City' &&
                                        _detectedCity == null) {
                                      _detectLocation();
                                    }
                                  });
                                },
                                activeColor: AppTheme.primary,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 1,
                                ),
                              ),
                              if (!isLast)
                                Divider(height: 1, color: AppTheme.divider),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  if (_location == 'City') ...[
                    if (_isLoadingLocation)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Detecting your city...',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
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
                                color: AppTheme.refusedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _openSettings,
                              child: const Text('Open Settings'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.refusedText,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSm),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_detectedCity != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySurface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                color: AppTheme.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Detected city: $_detectedCity',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showCitySelectionDialog(),
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: AppTheme.divider,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your country is always shown for context',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(color: AppTheme.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _shareDiscovery,
                          child: const Text(
                            'Share',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
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

  void _shareDiscovery() async {
    final locationText = _getLocationDisplayText();
    final feedService = FeedService();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        content: Row(
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            const SizedBox(width: 16),
            Text(
              'Sharing to community...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );

    try {
      // Prepare location data
      Map<String, dynamic> locationData;
      switch (_location) {
        case 'Morocco only':
          locationData = {'level': 'country', 'country': 'Morocco'};
          break;
        case 'None':
          locationData = {'level': 'none', 'country': 'Morocco'};
          break;
        default:
          // City level - use detected city if available, otherwise use selected city
          final cityName = _detectedCity ?? _location;
          locationData = {
            'level': 'city',
            'country': 'Morocco',
            'city': cityName,
          };
          break;
      }

      // Get plant data from identification
      final plant = widget.identification['plant'];
      final plantId = plant['_id'] ?? plant['id'] ?? 'unknown';
      final plantName = plant['name'] ?? 'Unknown Plant';
      final scientificName = plant['scientificName'] ?? 'Unknown';

      // Debug logging
      print(
          'DEBUG: Plant data from history - ID: $plantId, Name: $plantName, Scientific: $scientificName');

      // Get image URL
      final images = widget.identification['photoUrls'] as List<dynamic>? ?? [];
      final imageUrl = images.isNotEmpty ? images.first : null;

      // Get identification ID
      final identificationIds =
          widget.identification['identificationIds'] as List<dynamic>? ?? [];
      final identificationId =
          identificationIds.isNotEmpty ? identificationIds.first : null;

      // Fetch approved translations for the plant
      String? approvedDarija;
      String? approvedTamazight;

      if (scientificName != 'Unknown') {
        try {
          approvedDarija =
              await PlantTranslations.getDarijaName(scientificName);
          approvedTamazight =
              await PlantTranslations.getTamazightName(scientificName);

          // Only use translations if they're different from the scientific name
          if (approvedDarija == scientificName) {
            approvedDarija = null;
          }
          if (approvedTamazight == scientificName) {
            approvedTamazight = null;
          }

          print('DEBUG: Approved Darija: $approvedDarija');
          print('DEBUG: Approved Tamazight: $approvedTamazight');
        } catch (e) {
          print('DEBUG: Error fetching translations: $e');
          // Continue without translations if fetch fails
        }
      }

      // Share to feed
      final result = await feedService.shareToFeed(
        plantId: plantId,
        plantName: plantName,
        scientificName: scientificName,
        imageUrl: imageUrl,
        identificationId: identificationId,
        suggestedDarija: approvedDarija,
        suggestedTamazight: approvedTamazight,
        isAnonymous: _postAs == 'Anonymous',
        location: locationData,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (result['success']) {
        // Show success message
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Discovery Posted!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your discovery has been posted ${_postAs == 'Anonymous' ? 'anonymously' : 'as $_postAs'} and will be visible to the community.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Location: $locationText',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to detail screen
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            title: Row(
              children: [
                Icon(Icons.error, color: AppTheme.refusedText),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.refusedText,
                  ),
                ),
              ],
            ),
            content: Text(
              result['message'] ?? 'Failed to share discovery',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: AppTheme.refusedText),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.refusedText,
                ),
              ),
            ],
          ),
          content: Text(
            'Failed to share discovery: $e',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
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
