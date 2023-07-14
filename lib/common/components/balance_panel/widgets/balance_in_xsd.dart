import 'package:datadashwallet/features/home/home/home_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../common.dart';

class BalanceInXSD extends HookConsumerWidget {
  final double? fontSize;
  const BalanceInXSD({super.key, this.fontSize = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(homeContainer.actions);
    final state = ref.watch(homeContainer.state);
    final balance =
        Formatter.formatNumberForUI(state.walletBalance, isWei: false);

    return RichText(
        text: TextSpan(children: [
      TextSpan(
          text: balance,
          style: FontTheme.of(context).h5().copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              foreground: presenter.state.hideBalance == true
                  ? (Paint()
                    ..style = PaintingStyle.fill
                    ..color = Colors.white
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6))
                  : null)),
      TextSpan(
          text: ' XSD',
          style: FontTheme.of(context).h5().copyWith(
                fontSize: fontSize,
                color: ColorsTheme.of(context).textPrimary.withOpacity(0.32),
                fontWeight: FontWeight.w400,
              )),
    ]));
  }
}
