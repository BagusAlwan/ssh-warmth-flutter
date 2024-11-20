import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _takePicture(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      Navigator.pushNamed(
        context,
        '/confirmation',
        arguments: image.path,
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
          'WARMTH DETECTION',
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
