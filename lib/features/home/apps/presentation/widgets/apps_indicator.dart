import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class AppsIndicator extends StatelessWidget {
  const AppsIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 24,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
          color: Color(0xFF252525),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsTheme.of(context).primaryButton,
              ),
            ),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsTheme.of(context).primaryButton.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
