import 'dart:io';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import '../services/image_classification_service.dart';

class ConfirmationScreen extends StatelessWidget {
  final String imagePath;

  ConfirmationScreen({required this.imagePath}) : assert(imagePath.isNotEmpty);

  final ImageClassificationService _imageClassificationService =
      ImageClassificationService();

  Future<void> _classifyImage(BuildContext context) async {
    try {
      debugFileDetails();

      showLoadingDialog(context);

      final warmthData =
          await _imageClassificationService.classifyImage(File(imagePath));

      final warmthIndex = (warmthData['warmth_index'] as num?)?.toDouble() ?? 0.0;

      Navigator.pop(context);
      Navigator.pushNamed(context, '/additional-info', arguments: warmthIndex);
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      showErrorDialog(context, e.toString());
    }
  }

  void debugFileDetails() {
    print('File path: $imagePath');
    print('File exists: ${File(imagePath).existsSync()}');
    print('File name: ${File(imagePath).uri.pathSegments.last}');
    print('File MIME type: ${lookupMimeType(imagePath)}');
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty || !File(imagePath).existsSync()) {
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

    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
