import 'package:dio/dio.dart';

class RecommendationService {
  final Dio _dio = Dio();
  final String _recommendationUrl = 'http://url';

  Future<List<String>> getRecommendations({
    required Map<String, double> warmthIndices,
    required String lat,
    required String lon,
  }) async {
    try {
      final response = await _dio.post(
        _recommendationUrl,
        data: {
          'warmthIndices': warmthIndices,
          'lat': lat,
          'lon': lon,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return List<String>.from(response.data['recommendations']);
      } else {
        throw Exception('Failed to fetch recommendations');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}
