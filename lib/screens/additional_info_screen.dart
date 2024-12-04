import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/recommendation_service.dart';

class AdditionalInfoScreen extends StatelessWidget {
  final RecommendationService _recommendationService = RecommendationService();

  Future<Position> _getDeviceLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _getRecommendations(BuildContext context, double warmthIndex) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      final Position position = await _getDeviceLocation();

      final lat = position.latitude.toString();
      final lon = position.longitude.toString();

      final recommendations = await _recommendationService.getRecommendations(
        warmthIndices: warmthIndex,
        lat: lat,
        lon: lon,
      );

      Navigator.pop(context);

      Navigator.pushNamed(
        context,
        '/warm-result',
        arguments: recommendations,
      );
    } catch (e) {
      Navigator.pop(context);

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
    // Retrieve the warmthIndex from the route arguments
    final warmthIndex = ModalRoute.of(context)?.settings.arguments;

    // Check if warmthIndex is null or not a double
    if (warmthIndex == null || warmthIndex is! double) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Additional Information'),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'Invalid warmth index provided.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    // Proceed with valid warmthIndex
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Information'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Warmth Index:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                warmthIndex.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _getRecommendations(context, warmthIndex),
                child: Text('Get Recommendations'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
