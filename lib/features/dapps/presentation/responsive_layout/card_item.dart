import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CardCrossAxisCount {
  static const int mobile = 4;
  static const int tablet = 5;
}

class CardMainAxisCount {
  static const int mobile = 3;
  static const int tablet = 4;
}


class CardSizes {
  static Widget large({required Widget child}) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 4,
      mainAxisCellCount: 2,
      child: child,
    );
  }

  static Widget medium({required Widget child}) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      child: child,
    );
  }

  static Widget small({required Widget child}) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: child,
    );
  }
}
