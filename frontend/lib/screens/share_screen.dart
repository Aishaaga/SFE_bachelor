import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/location_service.dart';
import '../services/feed_service.dart';
import '../services/profile_service.dart';
import '../services/cloudinary_service.dart';
import '../data/plant_translations.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_theme.dart';

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
  final ProfileService _profileService = ProfileService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  String _postAs = 'Ahmed';
  String _location = '';
  String? _username;
  String? _detectedCity;
  bool _isLoadingLocation = false;
  bool _locationPermissionDenied = false;

  // Location levels
  late List<String> _locationLevels;
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
    _locationLevels = ['Morocco only', 'City', 'None'];
    _location = _locationLevels[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _locationLevels = [l10n.moroccoOnly, l10n.cityLevel, l10n.noLocation];
    if (_location == 'Morocco only' ||
        _location == 'City' ||
        _location == 'None') {
      _location = _locationLevels[0];
    }
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
    final l10n = AppLocalizations.of(context)!;
    if (level == l10n.moroccoOnly) return l10n.moroccoOnly;
    if (level == l10n.cityLevel) return l10n.cityLevel;
    if (level == l10n.noLocation) return l10n.noLocation;
    return level;
  }

  String _getLocationSubtitle(String level) {
    final l10n = AppLocalizations.of(context)!;
    if (level == l10n.moroccoOnly) return l10n.showOnlyCountryLevel;
    if (level == l10n.cityLevel) return l10n.showYourSpecificCity;
    if (level == l10n.noLocation) return l10n.hideLocationCompletely;
    return '';
  }

  void _showCitySelectionDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          l10n.selectCity,
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
              l10n.cancel,
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text(
          l10n.shareDiscovery,
          style: const TextStyle(
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
                  // Plant photo
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Image.file(
                          widget.photo,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Post as section
                  Text(
                    l10n.postAs,
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
                          title: Text(
                            l10n.anonymous,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          value: l10n.anonymous,
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
                    l10n.location,
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
                                    if (value == l10n.cityLevel &&
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
                  // City selection and detection
                  if (_location == l10n.cityLevel) ...[
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
                              l10n.detectingYourCity,
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
                              l10n.locationPermissionDenied,
                              style: TextStyle(
                                color: AppTheme.refusedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _openSettings,
                              child: Text(l10n.openSettings),
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
                                '${l10n.detectedCity} $_detectedCity',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showCitySelectionDialog(),
                              child: Text(
                                l10n.change,
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
                            l10n.yourCountryIsAlwaysShownForContext,
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
                            l10n.cancel,
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
                          child: Text(
                            l10n.share,
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.sharingToCommunity,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );

    try {
      // Upload image to Cloudinary
      final cloudinaryUrl = await _cloudinaryService.uploadImage(widget.photo);
      if (cloudinaryUrl == null) {
        Navigator.pop(context); // Close loading dialog
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
                  l10n.error,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.refusedText,
                  ),
                ),
              ],
            ),
            content: Text(
              'Failed to upload image to Cloudinary',
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
                  l10n.ok,
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }

      // Prepare location data
      Map<String, dynamic> locationData;
      if (_location == l10n.moroccoOnly) {
        locationData = {'level': 'country', 'country': 'Morocco'};
      } else if (_location == l10n.noLocation) {
        locationData = {'level': 'none', 'country': 'Morocco'};
      } else {
        // City level - use detected city if available, otherwise use selected city
        final cityName = _detectedCity ?? _location;
        locationData = {
          'level': 'city',
          'country': 'Morocco',
          'city': cityName,
        };
      }

      // Debug logging - check all available plant fields
      print('DEBUG: Plant object: ${widget.plant.toString()}');
      print(
          'DEBUG: Plant data - ID: ${widget.plant.id}, Name: ${widget.plant.name}, Scientific: ${widget.plant.scientificName}');
      print('DEBUG: Identification ID: ${widget.identificationId}');

      // Try to get a meaningful plant ID
      String plantId = 'unknown';
      if (widget.plant.id.isNotEmpty) {
        plantId = widget.plant.id;
      } else if (widget.identificationId != null) {
        plantId = 'plant_${widget.identificationId}';
      }

      print('DEBUG: Final plant ID: $plantId');
      print('DEBUG: Plant scientificName: "${widget.plant.scientificName}"');
      print('DEBUG: Plant name: "${widget.plant.name}"');

      // Fetch approved translations for the plant
      String? approvedDarija;
      String? approvedTamazight;

      if (widget.plant.scientificName.isNotEmpty) {
        try {
          print(
              'DEBUG: Attempting to fetch translations for: "${widget.plant.scientificName}"');
          approvedDarija = await PlantTranslations.getDarijaName(
              widget.plant.scientificName);
          approvedTamazight = await PlantTranslations.getTamazightName(
              widget.plant.scientificName);

          print('DEBUG: Raw Darija result: "$approvedDarija"');
          print('DEBUG: Raw Tamazight result: "$approvedTamazight"');

          // Only use translations if they're different from the scientific name
          if (approvedDarija == widget.plant.scientificName) {
            approvedDarija = null;
            print('DEBUG: Darija same as scientific name, setting to null');
          }
          if (approvedTamazight == widget.plant.scientificName) {
            approvedTamazight = null;
            print('DEBUG: Tamazight same as scientific name, setting to null');
          }

          print('DEBUG: Final Approved Darija: $approvedDarija');
          print('DEBUG: Final Approved Tamazight: $approvedTamazight');
        } catch (e) {
          print('DEBUG: Error fetching translations: $e');
          // Continue without translations if fetch fails
        }
      } else {
        print('DEBUG: Scientific name is empty, skipping translation fetch');
      }

      // Share to feed with Cloudinary URL
      final result = await feedService.shareToFeed(
        plantId: plantId,
        plantName:
            widget.plant.name.isNotEmpty ? widget.plant.name : 'Unknown Plant',
        scientificName: widget.plant.scientificName.isNotEmpty
            ? widget.plant.scientificName
            : 'Unknown',
        imageUrl: cloudinaryUrl,
        identificationId: widget.identificationId,
        suggestedDarija: approvedDarija,
        suggestedTamazight: approvedTamazight,
        isAnonymous: _postAs == l10n.anonymous,
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
                  l10n.discoveryPosted,
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
                  '${l10n.yourDiscoveryHasBeenPosted} ${_postAs == l10n.anonymous ? l10n.anonymously : '${l10n.as} $_postAs'} ${l10n.andWillBeVisibleToTheCommunity}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.location}: $locationText',
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
                  Navigator.pop(context); // Go back to result screen
                },
                child: Text(
                  l10n.ok,
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
                  l10n.error,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.refusedText,
                  ),
                ),
              ],
            ),
            content: Text(
              result['message'] ?? l10n.failedToShareDiscovery,
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
                  l10n.ok,
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
                l10n.error,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.refusedText,
                ),
              ),
            ],
          ),
          content: Text(
            '${l10n.failedToShareDiscovery}: $e',
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
                l10n.ok,
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
    final l10n = AppLocalizations.of(context)!;
    if (_location == l10n.moroccoOnly) return l10n.moroccoOnly;
    if (_location == l10n.noLocation) return l10n.noLocation;
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
