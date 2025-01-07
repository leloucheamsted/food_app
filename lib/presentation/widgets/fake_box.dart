import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FakeBox extends StatelessWidget {
  const FakeBox({
    required this.width,
    required this.height,
    super.key,
    this.child,
  });
  final Widget? child;

  final double width;
  final double height;

  static const _boxDecoration = BoxDecoration(
    color: Color(0xFFE2D8D7),
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor:  Colors.grey.shade300,
        highlightColor:  Colors.grey.shade100,
        child: Container(
          width: width,
          height: height,
          decoration: _boxDecoration.copyWith(color: Colors.white),
          child: child,
        ));
  }
}
