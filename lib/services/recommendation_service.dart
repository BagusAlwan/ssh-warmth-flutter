import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class RecommendationService {
  final Dio _dio = Dio();
  final String _recommendationUrl = 'http://192.168.24.5:3000/recommendation';

  Future<List<String>> getRecommendations({
    required double warmthIndices,
    required String lat,
    required String lon,
  }) async {
    try {
      final response = await _dio.post(
        _recommendationUrl,
        data: {
          'warmthIndex': warmthIndices,
          'lat': lat,
          'lon': lon,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201) {
        return List<String>.from(response.data['recommendations']);
      } else {
        throw Exception('Failed to fetch recommendations');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}
