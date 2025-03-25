import 'package:slike/utils/color.dart';
import 'package:slike/widget/myimage.dart';
import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final String? title, subTitle;
  const NoData({super.key, this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 15),
      decoration: BoxDecoration(
        color: transparent,
        borderRadius: BorderRadius.circular(12),
        shape: BoxShape.rectangle,
      ),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.5,
        minWidth: 0,
      ),
      child: Center(
        child: MyImage(
          width: MediaQuery.of(context).size.width > 1200 ? 300 : 200,
          height: MediaQuery.of(context).size.width > 1200 ? 300 : 200,
          fit: BoxFit.contain,
          imagePath: "nodata.png",
        ),
      ),
    );
  }
}
