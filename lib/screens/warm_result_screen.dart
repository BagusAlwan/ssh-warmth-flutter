import 'package:flutter/material.dart';

class WarmResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> recommendations =
        ModalRoute.of(context)!.settings.arguments as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendations'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Clothing Recommendations:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recommendations.map((rec) => Text(rec)),
          ],
        ),
      ),
    );
  }
}
