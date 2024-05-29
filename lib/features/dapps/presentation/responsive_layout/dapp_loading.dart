import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:shimmer/shimmer.dart';

import 'dapps_layout/card_item.dart';

class DAppLoading extends StatelessWidget {
  const DAppLoading({
    super.key,
    this.loading = false,
    this.crossAxisCount = CardCrossAxisCount.mobile,
    this.mainAxisCount = CardMainAxisCount.mobile,
  });

  final bool loading;
  final int crossAxisCount;
  final int mainAxisCount;

  @override
  Widget build(BuildContext context) {
    final cards = List.generate(crossAxisCount * mainAxisCount,
        (index) => Center(child: content(context)));

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: MediaQuery.of(context).size.width / mainAxisCount,
      ),
      scrollDirection: Axis.horizontal,
      children: cards,
    );
  }

  Widget content(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          height: width / 5,
          width: width / 5,
          child: shimmerAnimation(context),
        ),
        const SizedBox(
          height: Sizes.spaceXSmall,
        ),
        SizedBox(
            height: 12, width: width / 5, child: shimmerAnimation(context)),
      ],
    );
  }

  Widget shimmerAnimation(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0x33333333),
      highlightColor: const Color(0x00333333),
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
}
