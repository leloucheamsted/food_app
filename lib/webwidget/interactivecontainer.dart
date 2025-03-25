import 'package:flutter/material.dart';

class InteractiveContainer extends StatefulWidget {
  final Widget Function(bool isHovered) child;

  const InteractiveContainer({
    super.key,
    required this.child,
  });

  @override
  InteractiveContainerState createState() => InteractiveContainerState();
}

class InteractiveContainerState extends State<InteractiveContainer> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    // final hoverTransform = Matrix4.identity()
    //   ..translate(-5, -5, -5)
    //   ..scale(1.2);
    // final transform = _hovering ? hoverTransform : Matrix4.identity();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) => _hovered(true),
      onExit: (event) => _hovered(false),
      child: AnimatedContainer(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 800),
        child: widget.child(_hovering),
      ),
    );
  }

  _hovered(bool hovered) {
    setState(() {
      _hovering = hovered;
    });
  }
}
