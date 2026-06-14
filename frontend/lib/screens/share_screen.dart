import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../services/location_service.dart';
import '../services/feed_service.dart';
import '../services/profile_service.dart';
import '../l10n/app_localizations.dart';

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
        title: Text(l10n.selectCity),
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
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareDiscovery),
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
                        l10n.shareYourDiscovery,
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
                    l10n.postAs,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    title: Text(_username != null ? _username! : 'User'),
                    value: _username != null ? _username! : 'User',
                    groupValue: _postAs,
                    onChanged: (value) {
                      setState(() {
                        _postAs = value!;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  RadioListTile<String>(
                    title: Text(l10n.anonymous),
                    value: l10n.anonymous,
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
                    l10n.location,
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
                            if (value == l10n.cityLevel &&
                                _detectedCity == null) {
                              _detectLocation();
                            }
                          });
                        },
                        activeColor: Colors.green,
                      )),
                  // City selection and detection
                  if (_location == l10n.cityLevel) ...[
                    if (_isLoadingLocation)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircularProgressIndicator(
                                color: Colors.green),
                            const SizedBox(width: 16),
                            Text(l10n.detectingYourCity),
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
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _openSettings,
                              child: Text(l10n.openSettings),
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
                                '${l10n.detectedCity} $_detectedCity',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showCitySelectionDialog(),
                              child: Text(l10n.change),
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
                            l10n.yourCountryIsAlwaysShownForContext,
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
                          child: Text(l10n.cancel),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _shareDiscovery,
                          child: Text(l10n.share),
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

  void _shareDiscovery() async {
    final l10n = AppLocalizations.of(context)!;
    final locationText = _getLocationDisplayText();
    final feedService = FeedService();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l10n.sharingToCommunity),
          ],
        ),
      ),
    );

    try {
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

      // Share to feed
      final result = await feedService.shareToFeed(
        plantId: plantId,
        plantName:
            widget.plant.name.isNotEmpty ? widget.plant.name : 'Unknown Plant',
        scientificName: widget.plant.scientificName.isNotEmpty
            ? widget.plant.scientificName
            : 'Unknown',
        identificationId: widget.identificationId,
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
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(l10n.discoveryPosted),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.yourDiscoveryHasBeenPosted} ${_postAs == l10n.anonymous ? l10n.anonymously : '${l10n.as} $_postAs'} ${l10n.andWillBeVisibleToTheCommunity}',
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.location}: $locationText',
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
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      } else {
        // Show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(l10n.error),
              ],
            ),
            content: Text(result['message'] ?? l10n.failedToShareDiscovery),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
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
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.error),
            ],
          ),
          content: Text('${l10n.failedToShareDiscovery}: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
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
