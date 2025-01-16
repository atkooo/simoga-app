import 'package:flutter/material.dart';

class ExpandableButtonProvider with ChangeNotifier {
  int _expandedIndex = 0;

  int get expandedIndex => _expandedIndex;

  void setExpandedIndex(int index) {
    if (_expandedIndex == index) {
      _expandedIndex = 0;
    } else {
      _expandedIndex = index;
    }
    notifyListeners();
  }
}
