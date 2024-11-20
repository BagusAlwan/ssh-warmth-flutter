import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/recommendation_service.dart';

class AdditionalInfoScreen extends StatelessWidget {
  final RecommendationService _recommendationService = RecommendationService();

  Future<Position> _getDeviceLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show error if location services are not enabled
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show error if permission is denied
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show error if permissions are denied forever
      return Future.error('Location permissions are permanently denied.');
    }

    // Return the current position of the device
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _getRecommendations(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      // Get the device's current location
      final Position position = await _getDeviceLocation(context);

      final warmthIndices = Map<String, double>.from(data['warmthIndices']);
      final lat = position.latitude.toString();
      final lon = position.longitude.toString();

      final recommendations = await _recommendationService.getRecommendations(
        warmthIndices: warmthIndices,
        lat: lat,
        lon: lon,
      );

      Navigator.pushNamed(
        context,
        '/warm-result',
        arguments: recommendations,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> classificationResult =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final items = classificationResult['items'] as List<String>;
    final warmthIndices =
        classificationResult['warmthIndices'] as Map<String, double>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Information'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Detected Clothing Items:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...items.map((item) => Text('$item: ${warmthIndices[item]}')),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _getRecommendations(context, classificationResult),
            child: Text('Get Recommendations'),
          ),
        ],
      ),
    );
  }
}
