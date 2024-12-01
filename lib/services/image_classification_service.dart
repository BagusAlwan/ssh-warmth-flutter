import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class ImageClassificationService {
  final Dio _dio = Dio();
  final String _warmthUrl = 'http://localhost:8080/warmth';

  static const Map<String, int> clothingToWarmth = {
    'jacket': 3,
    'coat': 3,
    'sweater': 3,
    'cardigan': 3,
    'vest': 2,
    'pants': 2,
    'skirt': 2,
    'dress': 2,
    'tights, stockings': 2,
    'socks': 2,
    'shorts': 1,
    'top, t-shirt, sweatshirt': 1,
    'shirt, blouse': 1,
    'jumpsuit': 2,
    'hat': 2,
    'scarf': 2,
    'glove': 3,
    'shoe': 1,
    'bag, wallet': 1,
    'glasses': 1,
    'umbrella': 1,
    'headband, head covering, hair accessory': 1,
  };

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/yolov5s_model.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1,
      );
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    try {
      var recognitions = await Tflite.detectObjectOnImage(
        path: imageFile.path,
        model: "YOLO",
        threshold: 0.5,
      );

      recognitions ??= [];

      Map<String, dynamic> detectedItems =
          _mapDetectedItemsToWarmth(recognitions);

      var warmthData = await _sendWarmthDataToBackend(detectedItems);

      return warmthData;
    } catch (e) {
      throw Exception('Error classifying image: $e');
    }
  }

  Map<String, dynamic> _mapDetectedItemsToWarmth(List recognitions) {
    Map<String, dynamic> detectedItems = {};

    for (var recognition in recognitions) {
      final clothingName = recognition["label"];
      final confidence = recognition["confidence"];

      if (confidence >= 0.5 && clothingToWarmth.containsKey(clothingName)) {
        String warmth = _getWarmthLevel(clothingName);
        detectedItems[clothingName] = warmth;
      }
    }

    return detectedItems;
  }

  String _getWarmthLevel(String clothingName) {
    if (clothingToWarmth.containsKey(clothingName)) {
      int warmth = clothingToWarmth[clothingName]!;
      if (warmth == 3) {
        return 'high';
      } else if (warmth == 2) {
        return 'medium';
      } else {
        return 'low';
      }
    }
    return 'unknown';
  }

  Future<Map<String, dynamic>> _sendWarmthDataToBackend(
      Map<String, dynamic> detectedItems) async {
    Map<String, dynamic> layers = _mapDetectedItemsToLayers(detectedItems);

    try {
      final response = await _dio.post(
        _warmthUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode(layers),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to calculate warmth index');
      }
    } catch (e) {
      throw Exception('Error calculating warmth index: $e');
    }
  }

  Map<String, dynamic> _mapDetectedItemsToLayers(
      Map<String, dynamic> detectedItems) {
    Map<String, dynamic> layers = {
      'outerLayer': 0,
      'midLayer': 0,
      'baseLayer': 0,
      'lowerBody': 0,
      'accessories': 0,
    };

    detectedItems.forEach((item, warmth) {
      if (clothingToWarmth.containsKey(item)) {
        if (warmth == "high") {
          layers['outerLayer'] += clothingToWarmth[item];
        } else if (warmth == "medium") {
          layers['midLayer'] += clothingToWarmth[item];
        } else if (warmth == "low") {
          layers['baseLayer'] += clothingToWarmth[item];
        }
      }
    });

    return layers;
  }

  void dispose() {
    Tflite.close();
  }
}
