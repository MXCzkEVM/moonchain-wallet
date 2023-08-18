import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class DAppIndicator extends StatelessWidget {
  const DAppIndicator({
    super.key,
    this.selectedIndex = 0,
    this.total = 1,
  });

  final int selectedIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 24,
        width: total * 10 < 100 ? null : 100,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration:  BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          color: ColorsTheme.of(context).blackInvert,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            total,
            (index) => DAppsDot(
              isSelected: selectedIndex == index,
            ),
          ),
        ),
      ),
    );
  }
}

class DAppsDot extends StatelessWidget {
  const DAppsDot({
    super.key,
    this.isSelected = false,
  });

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? ColorsTheme.of(context).iconPrimary
            : ColorsTheme.of(context).iconPrimary.withOpacity(0.3),
      ),
    );
  }
}
