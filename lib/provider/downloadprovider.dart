import 'package:flutter/material.dart';

class DownloadProvider extends ChangeNotifier {
  double progress = 0.0;

  updateProgress(double prg) {
    progress = prg;
    notifyListeners();
  }
}
