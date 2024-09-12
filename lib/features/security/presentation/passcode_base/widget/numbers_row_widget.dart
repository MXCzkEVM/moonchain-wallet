import 'dart:math';

import 'package:moonchain_wallet/common/color_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../passcode_require/widgets/circle_animation.dart';

class NumbersRowWidget extends StatefulWidget {
  const NumbersRowWidget(
      {super.key,
      required this.expectedNumbersLength,
      required this.enteredNumbers,
      required this.shakeAnimationInit});

  final int expectedNumbersLength;
  final int enteredNumbers;
  final void Function(AnimationController) shakeAnimationInit;

  @override
  State<NumbersRowWidget> createState() => _NumbersRowWidgetState();
}

class _NumbersRowWidgetState extends State<NumbersRowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animationRotation;
  int shakeOffset = 10;
  int shakeCount = 4;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    final tweenSequenceList = [
      TweenSequenceItem<double>(
        tween: Tween(begin: 0, end: 2 * pi / 360),
        weight: 1,
      ),
      for (int i = 0; i < 6; i++)
        TweenSequenceItem<double>(
          tween: Tween(begin: 2 * pi / 360, end: -2 * pi / 360)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1,
        ),
      TweenSequenceItem<double>(
        tween: Tween(begin: 0, end: 0),
        weight: 1,
      ),
    ];

    _animationRotation = TweenSequence<double>(tweenSequenceList).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.addStatusListener(_updateStatus);

    widget.shakeAnimationInit(_animationController);
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_updateStatus);
    _animationController.dispose();
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationRotation.value,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < widget.expectedNumbersLength; i++) ...[
              Expanded(
                  child: CircleAnimation(
                isFilled: widget.enteredNumbers > i,
              ))
            ],
          ],
        ),
      ),
    );
  }
}
