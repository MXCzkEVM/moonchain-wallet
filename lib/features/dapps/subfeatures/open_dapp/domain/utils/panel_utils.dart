import 'dart:async';

import 'package:flutter/material.dart';

import '../../open_dapp.dart';

const double maxPanelHeight = 100.0;

const settleDuration = Duration(milliseconds: 400);
const cancelDuration = Duration(milliseconds: 400);

class PanelUtils {
  static void showPanel(OpenDAppState state, Timer? panelTimer) async {
    final status = state.animationController?.status;
    if (state.animationController?.value != 1 &&
            status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      await state.animationController?.animateTo(
        1.0,
        duration: settleDuration,
        curve: Curves.ease,
      );
      panelTimer = Timer(
        const Duration(seconds: 3),
        () => hidePanel(state, panelTimer),
      );
    }
  }

  static void hidePanel(OpenDAppState state, Timer? panelTimer) async {
    final status = state.animationController?.status;
    if (state.animationController?.value != 0 &&
        status == AnimationStatus.completed) {
      await state.animationController?.animateTo(
        0.0,
        duration: cancelDuration,
        curve: Curves.easeInExpo,
      );
      if (panelTimer != null) {
        panelTimer.cancel();
      }
    }
  }
}
