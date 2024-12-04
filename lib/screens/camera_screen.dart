import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;

  String appBarTitle = "Loading..."; // Default title before fetching data

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fetchServerData(); // Fetch the title from the server
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _cameraController.initialize();

    setState(() {});
  }

  Future<void> _fetchServerData() async {
    try {
      // Replace with your server URL
      final response = await http.get(Uri.parse('http://192.168.24.5:3000'));
      if (response.statusCode == 200) {
        setState(() {
          appBarTitle = response.body; // Set the title to the response body
        });
      } else {
        setState(() {
          appBarTitle =
              "Error Fetching Data"; // Display an error if not successful
        });
      }
    } catch (e) {
      setState(() {
        appBarTitle = "Connection Error"; // Display connection error
      });
    }
  }

  Future<File> _convertToPng(File originalFile) async {
    try {
      // Read the image as bytes
      final imageBytes = await originalFile.readAsBytes();

      // Decode the image using the image package
      final img.Image? decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Encode the image to PNG
      final List<int> pngBytes = img.encodePng(decodedImage);

      // Save the PNG image to a new file
      final String newPath = originalFile.path.replaceAll('.jpg', '.png');
      final File pngFile = File(newPath);
      await pngFile.writeAsBytes(pngBytes);

      print('Image converted to PNG: ${pngFile.path}');
      return pngFile;
    } catch (e) {
      print('Error converting image to PNG: $e');
      throw Exception('Error converting image to PNG');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _takePicture(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      final XFile image = await _cameraController.takePicture();

      // Convert the image to PNG
      final File originalFile = File(image.path);
      final File pngFile = await _convertToPng(originalFile);

      // Navigate to the confirmation screen with the PNG file path
      Navigator.pushNamed(
        context,
        '/confirmation',
        arguments: pngFile.path,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle, // Use the fetched title
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              //Nothing for now
            },
          )
        ],
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Center the camera preview
              return CameraPreview(_cameraController);
            } else {
              // Center the progress indicator
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[800],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              color: Colors.white,
              onPressed: () {
                //Nothing yet
              },
            ),
            GestureDetector(
              onTap: () {
                _takePicture(context);
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 40.0,
                  color: Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.attach_file),
              color: Colors.white,
              onPressed: () {
                //Nothign yet
              },
            ),
          ],
        ),
      ),
    );
  }
}
