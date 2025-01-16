import 'package:flutter/material.dart';
import '../service/model_service_android.dart';

class ModelServiceProvider with ChangeNotifier {
  bool _isModelLoaded = false;
  bool get isModelLoaded => _isModelLoaded;

  ModelServiceProvider() {
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    await ModelService.loadModel();
    await ModelService.loadLabels();
    _isModelLoaded = true;
    notifyListeners();
  }
}
