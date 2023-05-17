import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MxcScrollBehavior extends ScrollBehavior {
  const MxcScrollBehavior({
    this.scrollPhysics,
  });
  final ScrollPhysics? scrollPhysics;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return scrollPhysics ?? super.getScrollPhysics(context);
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
