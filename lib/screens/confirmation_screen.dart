import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_classification_service.dart';

class ConfirmationScreen extends StatelessWidget {
  final String imagePath; // Add a field to hold the image path

  // Constructor to accept the image path
  ConfirmationScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Check if the file exists before proceeding
    if (!File(imagePath).existsSync()) {
      // Handle case where the file path is invalid or doesn't exist
      return Scaffold(
        appBar: AppBar(
          title: Text('Confirm Photo'),
        ),
        body: Center(
          child: Text(
            'Error: Image file not found',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    final ImageClassificationService _imageClassificationService =
        ImageClassificationService();

    Future<void> _classifyImage(BuildContext context) async {
      try {
        // Show loading indicator while processing
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Classify the image and get the result (warmth index)
        final warmthData =
            await _imageClassificationService.classifyImage(File(imagePath));

// Extract warmth index from the response data
        final warmthIndex =
            warmthData['warmthIndex']; // warmthIndex: 0.4 (for example)

// Close the loading dialog
        Navigator.pop(context);

// Navigate to the next screen with the warmth index data
        Navigator.pushNamed(
          context,
          '/additional-info',
          arguments:
              warmthIndex, // Pass the warmthIndex directly to the next screen
        );
      } catch (e) {
        Navigator.pop(context); // Close the loading dialog

        // Show error dialog if something goes wrong
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

    return Scaffold(
      backgroundColor: Colors.grey[800], // Match the background color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Top Text
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Proceed with this photo?',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Image Preview
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover, // Adjust the image to fit
                ),
              ),
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.arrow_back,
                      size: 30.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Confirm Button
                GestureDetector(
                  onTap: () => _classifyImage(context),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.check,
                      size: 30.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
