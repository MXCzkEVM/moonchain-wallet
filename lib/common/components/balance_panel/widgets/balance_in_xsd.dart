import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

class BalanceInXSD extends HookConsumerWidget {
  const BalanceInXSD({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _accountUseCase = ref.watch(accountUseCaseProvider);
    final state = ref.watch(walletContainer.state);
    final walletBalance = double.parse(state.walletBalance);
    double balanceConverter = state.xsdConversionRate == 1.0
        ? walletBalance
        : state.xsdConversionRate * walletBalance;
    final balance = MXCFormatter.formatNumberForUI(balanceConverter.toString());
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
      Text(_accountUseCase.getXsdUnit(),
          style: FontTheme.of(context).body2().copyWith(
                color: ColorsTheme.of(context).textSecondary,
              )),
    ]);
  }
}
