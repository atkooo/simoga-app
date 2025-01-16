import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ModelService {
  static Interpreter? interpreter;
  static Map<int, String> labels = {};

  static Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/tflite/model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  static Future<void> loadLabels() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/tflite/label_simoga.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      labels = jsonMap
          .map((key, value) => MapEntry(int.parse(key), value as String));
      print('Labels loaded: $labels');
    } catch (e) {
      print('Failed to load labels: $e');
    }
  }

  static void dispose() {
    interpreter?.close();
  }
}

class ImageUtils {
  static Future<List<Map<String, dynamic>>?> classifyImage(File image) async {
    if (ModelService.interpreter == null) {
      print('Interpreter is not loaded');
      return null;
    }

    final bytes = await image.readAsBytes();
    final img.Image? imageInput = img.decodeImage(bytes);
    if (imageInput == null) {
      print('Cannot decode image');
      return null;
    }
    final img.Image resizedImage =
        img.copyResize(imageInput, width: 224, height: 224);

    var input = Float32List(1 * 224 * 224 * 3);
    var buffer = Float32List.view(input.buffer);
    int pixelIndex = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        buffer[pixelIndex++] = img.getRed(pixel) / 255.0;
        buffer[pixelIndex++] = img.getGreen(pixel) / 255.0;
        buffer[pixelIndex++] = img.getBlue(pixel) / 255.0;
      }
    }

    var reshapedInput = input.reshape([1, 224, 224, 3]);
    var output = List.filled(1 * 58, 0.0).reshape([1, 58]);

    try {
      ModelService.interpreter!.run(reshapedInput, output);
      print('Output: $output');
    } catch (e) {
      print('Error running model: $e');
      return null;
    }

    List<Map<String, dynamic>> predictions = [];
    for (int i = 0; i < output[0].length; i++) {
      predictions.add({
        'index': i,
        'confidence': output[0][i],
        'label': ModelService.labels[i] ?? 'Unknown'
      });
    }

    predictions.sort((a, b) => b['confidence'].compareTo(a['confidence']));
    return predictions.take(4).toList();
  }
}
