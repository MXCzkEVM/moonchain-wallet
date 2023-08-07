import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../common.dart';

class BalanceInXSD extends HookConsumerWidget {
  const BalanceInXSD({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletContainer.state);
    final balance =
        Formatter.formatNumberForUI(state.walletBalance, isWei: false);

    return Row(children: [
      Text(balance,
          style: FontTheme.of(context).body2().copyWith(
              color: state.hideBalance == true
                  ? null
                  : ColorsTheme.of(context).textPrimary,
              foreground: state.hideBalance == true
                  ? (Paint()
                    ..style = PaintingStyle.fill
                    ..color = Colors.white
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6))
                  : null)),
      const SizedBox(width: 4),
      Text(state.xsdConversionRate == 2.0 ? 'XSD' : 'X',
          style: FontTheme.of(context).body2().copyWith(
                color: ColorsTheme.of(context).textSecondary,
              )),
    ]);
  }
}
