import 'package:flutter/material.dart';

class FeedPlayerProvider extends ChangeNotifier {
  bool? showPrevious;
  bool? showNext;

  showPreviusIcon() {
    showPrevious = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1000), () {
      clearProvider();
    });
  }

  showNextIcon() {
    showNext = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1000), () {
      clearProvider();
    });
  }

  clearProvider() {
    showPrevious = null;
    showNext = null;
  }
}
