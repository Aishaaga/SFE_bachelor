import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  final String _cloudName = 'ddgsxpi5o';
  final String _uploadPreset =
      'sfe_app_preset'; // Update this with your actual upload preset name from Cloudinary dashboard
  final Dio _dio = Dio();

  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadImage(File imageFile) async {
    try {
      print('☁️ Uploading image to Cloudinary...');
      print('📁 File path: ${imageFile.path}');
      print('📏 File size: ${await imageFile.length()} bytes');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'upload_preset': _uploadPreset,
        'folder': 'sfe_plants',
      });

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final secureUrl = response.data['secure_url'];
        print('✅ Image uploaded successfully: $secureUrl');
        return secureUrl;
      } else {
        print('❌ Cloudinary upload failed: ${response.statusCode}');
        print('❌ Error details: ${response.data}');
        if (response.data is Map && response.data['error'] != null) {
          print(
              '❌ Cloudinary error message: ${response.data['error']['message']}');
        }
        return null;
      }
    } on DioException catch (e) {
      print('❌ DioException uploading to Cloudinary: ${e.message}');
      print('❌ Response: ${e.response}');
      print('❌ Response data: ${e.response?.data}');
      if (e.response?.data is Map && e.response?.data['error'] != null) {
        print('❌ Cloudinary error: ${e.response?.data['error']['message']}');
      }
      return null;
    } catch (e) {
      print('❌ Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// Upload multiple images to Cloudinary
  /// Returns a list of secure URLs
  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    final urls = <String>[];

    for (final file in imageFiles) {
      final url = await uploadImage(file);
      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }
}
