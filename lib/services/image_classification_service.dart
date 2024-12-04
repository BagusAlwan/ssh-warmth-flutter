import 'dart:io';
import 'package:dio/dio.dart';

class ImageClassificationService {
  final Dio _dio;
  final String _backendUrl = 'http://192.168.24.5:3000/prediction';

  ImageClassificationService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 60),
          ),
        );

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    // Validate the file
    if (!imageFile.existsSync()) {
      throw Exception('Image file does not exist: ${imageFile.path}');
    }

    try {
      // Debug the file details
      print('Sending file: ${imageFile.path}');
      print('File size: ${imageFile.lengthSync()} bytes');

      // Create FormData
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.png',
        ),
      });

      print('FormData created: ${formData.fields}, file: ${formData.files}');

      final response = await _dio.post(
        _backendUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response received: ${response.data}');

        if (response.data is Map<String, dynamic>) {
          final responseData = response.data;

          if (responseData['success'] == true &&
              responseData['data'] is Map<String, dynamic>) {
            return responseData['data'];
          } else {
            throw Exception('Unexpected response format: ${response.data}');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to classify image: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioError) {
        print('DioError occurred: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        throw Exception(
          'DioError: ${e.response?.data ?? e.message}. '
          'Status code: ${e.response?.statusCode ?? 'unknown'}',
        );
      } else {
        print('Error occurred: $e');
        throw Exception('Error classifying image: $e');
      }
    }
  }
}
