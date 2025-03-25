import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:slike/utils/color.dart';
import 'package:slike/utils/utils.dart';
import 'package:slike/widget/myimage.dart';

class FullPhotoPage extends StatelessWidget {
  final String url;

  const FullPhotoPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        centerTitle: true,
        leading: InkWell(
          focusColor: transparent,
          highlightColor: transparent,
          hoverColor: transparent,
          splashColor: transparent,
          onTap: () {
            Navigator.of(context).pop(false);
          },
          child: Align(
            alignment: Alignment.center,
            child: MyImage(
              width: 30,
              height: 30,
              imagePath: "ic_roundback.png",
            ),
          ),
        ),
      ),
      body: PhotoView(
        loadingBuilder: (context, event) => Utils.pageLoader(context),
        imageProvider: NetworkImage(url),
      ),
    );
  }
}
