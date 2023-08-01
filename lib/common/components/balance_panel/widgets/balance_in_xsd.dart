import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/account/account_use_case.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../common.dart';

class BalanceInXSD extends HookConsumerWidget {
  final double? fontSize;
  const BalanceInXSD({super.key, this.fontSize = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    final state = ref.watch(walletContainer.state);
    final balance =
        Formatter.formatNumberForUI(state.walletBalance, isWei: false);

    return Row(children: [
      Text(balance,
          style: FontTheme.of(context).h5().copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
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
          style: FontTheme.of(context).h5().copyWith(
                fontSize: fontSize,
                color: ColorsTheme.of(context).textSecondary,
                fontWeight: FontWeight.w400,
              )),
    ]);
  }
}
