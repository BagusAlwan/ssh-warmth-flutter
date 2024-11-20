import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';
import 'screens/confirmation_screen.dart';
import 'screens/additional_info_screen.dart';
import 'screens/warm_result_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warmth Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CameraScreen(),
        '/confirmation': (context) {
          // Retrieve the imagePath passed as arguments
          final String imagePath =
              ModalRoute.of(context)?.settings.arguments as String;
          return ConfirmationScreen(imagePath: imagePath);
        },
        '/additional-info': (context) => AdditionalInfoScreen(),
        '/warm-result': (context) => WarmResultScreen(),
      },
    );
  }
}
