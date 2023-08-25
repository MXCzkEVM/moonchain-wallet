import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:shimmer/shimmer.dart';

import 'card_item.dart';

class DAppLoading extends StatelessWidget {
  const DAppLoading({
    super.key,
    this.loading = false,
    this.crossAxisCount = CardCrossAxisCount.mobile,
  });

  final bool loading;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    Widget content() {
      return Shimmer.fromColors(
        baseColor: ColorsTheme.of(context).primary.withOpacity(0.2),
        highlightColor: ColorsTheme.of(context).primary,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            color: ColorsTheme.of(context).cardBackground,
          ),
        ),
      );
    }

    return StaggeredGrid.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      axisDirection: AxisDirection.down,
      children: [
        for (int i = 0; i < 2; i++) CardSizes.large(child: content()),
        for (int i = 0; i < 2; i++) CardSizes.medium(child: content()),
        for (int i = 0; i < 8; i++) CardSizes.small(child: content()),
        for (int i = 0; i < 2; i++) CardSizes.medium(child: content()),
      ],
    );
  }
}
