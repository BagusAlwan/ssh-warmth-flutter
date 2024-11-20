import 'dart:io';
import 'package:dio/dio.dart';

class ImageClassificationService {
  final Dio _dio = Dio();
  final String _classificationUrl = 'http://url';

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path,
            filename: 'clothing_image.jpg'),
      });

      final response = await _dio.post(
        _classificationUrl,
        data: formData,
        options: Options(headers: {
          'Content-Type': 'multipart/form-data',
        }),
      );

      if (response.statusCode == 200) {
        return response
            .data; // Server returns clothing items and warmth indices
      } else {
        throw Exception('Failed to classify image');
      }
    } catch (e) {
      throw Exception('Error classifying image: $e');
    }
  }
}
