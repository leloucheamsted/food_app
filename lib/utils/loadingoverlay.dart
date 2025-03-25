import 'package:flutter/material.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/widget/loading_ui.dart';

class LoadingOverlay {
  static final LoadingOverlay _singleton = LoadingOverlay._internal();
  factory LoadingOverlay() {
    return _singleton;
  }

  LoadingOverlay._internal();

  OverlayEntry? _overlayEntry;

  void show(BuildContext context) {
    if (_overlayEntry != null) return; // Prevent multiple overlays

    _overlayEntry = OverlayEntry(
      builder: (context) => const LoadingUi(color: colorAccent),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hide() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}
