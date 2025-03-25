import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slike/utils/utils.dart';

class MyQRProvider extends ChangeNotifier {
  ScreenshotController screenshotController = ScreenshotController();

  Future<String?> onCaptureImage() async {
    try {
      final directory = (await getApplicationDocumentsDirectory()).path;
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final String filePath = '$directory/$fileName.png';

      final image = await screenshotController.capture();
      if (image != null) {
        final file = File(filePath);
        await file.writeAsBytes(image);

        printLog("Capture Screen Shorts => $filePath");

        return filePath;
      } else {
        printLog("Capture Screen Shorts Failed => No image captured");
      }
    } catch (e) {
      printLog("Capture Screen Shorts Failed => $e");
    }

    return null;
  }

  Future<void> onClickDownload() async {
    try {
      final filePath = await onCaptureImage();
      if (filePath != null) {
        await GallerySaver.saveImage(filePath);
        Utils().showToast("Download Succsessfully");
      }
    } catch (e) {
      printLog("Download Screen Shorts Failed => $e");
    }
  }
}
