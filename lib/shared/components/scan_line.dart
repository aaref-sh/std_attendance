import 'package:flutter/material.dart';

class ColorChangingLine extends StatefulWidget {
  const ColorChangingLine({super.key});

  @override
  State<ColorChangingLine> createState() => _ColorChangingLineState();
}

class _ColorChangingLineState extends State<ColorChangingLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _colorAnimation =
        ColorTween(begin: Colors.red, end: Colors.white).animate(_controller)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2, // Set the desired height for the line
      color: _colorAnimation.value,
    );
  }
}
