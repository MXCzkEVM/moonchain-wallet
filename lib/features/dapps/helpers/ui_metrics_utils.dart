import 'package:mxc_logic/mxc_logic.dart';

class UIMetricsUtils {
  static getGridViewItemWidth(
    double viewPortWidth,
  ) {
    return viewPortWidth / 3;
  }

  static double calculateScrollingArea(double maxWidth) {
    return maxWidth - Config.edgeScrollingSensitivity;
  }
}
