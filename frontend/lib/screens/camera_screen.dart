import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sfe_mobile/services/gbif_service.dart';
import 'package:sfe_mobile/widgets/loading_widget.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import '../services/image_compression_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // DEBUG: Inspect the file
      final file = File(pickedFile.path);
      print('=== CAMERA FILE DEBUG ===');
      print('Path: ${pickedFile.path}');
      print('Name: ${pickedFile.name}');
      print('Exists: ${await file.exists()}');
      print('Size: ${await file.length()} bytes');
      print('=========================');

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _identifyPlant();
    }
  }

  Future<void> _identifyPlant() async {
    if (_selectedImage == null) return;

    LoadingDialog.show(
      context,
      message: '📸 Compression de l\'image...',
    );
    // Before creating the request

    try {
      // COMPRESS THE IMAGE BEFORE SENDING
      final compressedImage =
          await ImageCompressionService.compressImage(_selectedImage!);

      print('=== SENDING FILE ===');
      print('Path: ${compressedImage.path}');
      print('Exists: ${await compressedImage.exists()}');
      print('Size: ${await compressedImage.length()}');

      LoadingDialog.update(context, '🌿 Envoi à PlantNet...');

      final result = await _apiService.identifyPlant(compressedImage);

      LoadingDialog.update(context, '🗺️ Récupération de la distribution...');

      if (result['success'] && result['plant'] != null) {
        final distributionFuture =
            GBIFService.getOccurrenceCount(result['plant'].scientificName);

        // Wait for both (or timeout after 5 seconds)
        final distributionCount = await distributionFuture.timeout(
          Duration(seconds: 5),
          onTimeout: () => 0,
        );

        LoadingDialog.hide(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              plant: result['plant'],
              photo: compressedImage,
              identificationId: result['identificationId'],
            ),
          ),
        ).then((_) {
          // Revenir à l'écran caméra, réinitialiser
          LoadingDialog.hide(context);
        });
      } else {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      LoadingDialog.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identifier une plante'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.feed),
            tooltip: 'Community Feed',
            onPressed: () {
              Navigator.pushNamed(context, '/feed');
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Identification en cours...'),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedImage != null)
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: Image.file(
                        _selectedImage!,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Appareil photo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galerie'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_selectedImage != null && !_isLoading)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      child: const Text('Changer de photo'),
                    ),
                ],
              ),
            ),
    );
  }
}
