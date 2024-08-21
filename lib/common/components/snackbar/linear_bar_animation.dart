import 'package:flutter/material.dart';

class LinearBarAnimation extends StatefulWidget {
  final Color color;
  const LinearBarAnimation({super.key, required this.color});

  @override
  State<LinearBarAnimation> createState() => _LinearBarAnimationState();
}

class _LinearBarAnimationState extends State<LinearBarAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
      upperBound: 1,
      lowerBound: 0,
      value: 0,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: 2,
            width: _controller.value *
                MediaQuery.of(
                  context,
                ).size.width,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.color,
                  blurRadius: 1,
                  spreadRadius: 1.0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
