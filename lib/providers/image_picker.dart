import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageProviderNotifier extends ChangeNotifier {
  XFile? _pickedImage;

  XFile? get pickedImage => _pickedImage;

  void setPickedImage(XFile image) {
    _pickedImage = image;
    notifyListeners();
  }
}
