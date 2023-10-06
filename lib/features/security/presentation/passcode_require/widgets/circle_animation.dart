import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class CircleAnimation extends StatefulWidget {
  const CircleAnimation({super.key, required this.isFilled});

  final bool isFilled;

  @override
  State<CircleAnimation> createState() => _CircleAnimationState();
}

class _CircleAnimationState extends State<CircleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationSize;
  late Animation<double> _animationOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animationSize = Tween<double>(begin: 57.5, end: 32.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _animationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.isFilled ? _controller.forward() : _controller.reverse();
    return SizedBox(
      height: 57.5,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Center(
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorsTheme.of(context).iconWhite, width: 2),
                  shape: BoxShape.circle,
                  color: Colors.transparent),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Center(
                child: Opacity(
                  opacity: _animationOpacity.value,
                  child: Container(
                    height: _animationSize.value,
                    width: _animationSize.value,
                    decoration: BoxDecoration(
                      color: ColorsTheme.of(context).iconWhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
            // child: ,
          ),
        ],
      ),
    );
  }
}
