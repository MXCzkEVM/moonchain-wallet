import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../presentation/dapps_state.dart';

class GestureNavigationHelper {
  GestureNavigationHelper({
    required this.state,
    required this.context,
    required this.scrollController,
    required this.translate,
    required this.scrollingArea,
  });
  DAppsState state;
  BuildContext? context;
  String? Function(String) translate;
  ScrollController scrollController;
  double? scrollingArea;

  void handleOnDragUpdate(Offset position) {
    print(position.dx < 0);
    print(position.dx > scrollingArea!);
    if (position.dx <= Config.edgeScrollingSensitivity) {
      startTimer();
      state.onLeftEdge = true;
    } else if (position.dx > scrollingArea!) {
      startTimer();
      state.onRightEdge = true;
    } else {
      cancelTimer();
    }

    print('position: ' + position.toString());
  }

  void changePageToLeft() {
    scrollController.animateTo(
        scrollController.position.pixels - MediaQuery.of(context!).size.width,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut);
  }

  void changePageToRight() {
    scrollController.animateTo(
        scrollController.position.pixels + MediaQuery.of(context!).size.width,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut);
  }

  void cancelTimer() {
    state.timer?.cancel();
    state.timer = null;
    resetLeftAndRight();
  }

  void resetLeftAndRight() {
    state.onLeftEdge = false;
    state.onRightEdge = false;
  }

  void startTimer() {
    print('timer' + state.timer.toString());
    state.timer ??= Timer(Config.dragScrollingDuration, () {
      if (state.onLeftEdge) {
        changePageToLeft();
      } else if (state.onRightEdge) {
        changePageToRight();
      }
      resetLeftAndRight();
    });
  }
}
