import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

class CloudinaryDataSource {
  final http.Client _client;
  CloudinaryDataSource(this._client);

  /// Upload a single image file to Cloudinary unsigned preset.
  /// Returns the secure URL of the uploaded image.
  Future<String> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConstants.cloudinaryUploadUrl),
      )
        ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw UploadException(
          'Upload failed with status ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['secure_url'] as String;
    } catch (e) {
      if (e is UploadException) rethrow;
      throw UploadException('Failed to upload image: $e');
    }
  }

  /// Upload multiple images — returns list of secure URLs.
  Future<List<String>> uploadImages(List<String> filePaths) async {
    final futures = filePaths.map(uploadImage);
    return Future.wait(futures);
  }
}
