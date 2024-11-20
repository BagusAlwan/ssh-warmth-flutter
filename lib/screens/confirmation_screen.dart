import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_classification_service.dart';

class ConfirmationScreen extends StatelessWidget {
  final String imagePath; // Add a field to hold the image path

  // Constructor to accept the image path
  ConfirmationScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
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
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        final classificationResult =
            await _imageClassificationService.classifyImage(File(imagePath));

        Navigator.pop(context);

        Navigator.pushNamed(
          context,
          '/additional-info',
          arguments: classificationResult,
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
