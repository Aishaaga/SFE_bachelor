import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressionService {
  /// Compress image file to reduce size
  /// Returns compressed File
  static Future<File> compressImage(File imageFile) async {
    // Get original file size
    final originalSize = await imageFile.length();
    print(
        '📸 Original image size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');

    // If image is smaller than 1MB, don't compress
    if (originalSize < 1024 * 1024) {
      print('✅ Image already small enough, no compression needed');
      return imageFile;
    }

    // Create temporary directory for compressed image
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Compress image
    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      quality: 70, // 70% quality (good balance)
      minWidth: 1200, // Max width 1200px
      minHeight: 1200, // Max height 1200px
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      print('⚠️ Compression failed, using original image');
      return imageFile;
    }

    final compressedSize = await result.length();
    print(
        '✅ Compressed image size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
    print(
        '📉 Saved: ${((1 - compressedSize / originalSize) * 100).toStringAsFixed(0)}% space');

    return File(result.path);
  }
}
