import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../common.dart';

class BalanceTitle extends HookConsumerWidget {
  final double? fontSize;
  const BalanceTitle({super.key, this.fontSize = 16});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    final state = ref.watch(walletContainer.state);
    return Row(
      children: [
        Text(FlutterI18n.translate(context, 'balance'),
            style: FontTheme.of(context).body1().copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: ColorsTheme.of(context).textSecondary)),
        const SizedBox(
          width: 4,
        ),
        MxcCircleButton.icon(
          key: const Key("balanceHideButton"),
          icon: state.hideBalance ? MXCIcons.show : MXCIcons.hide,
          shadowRadius: 16,
          onTap: () {
            presenter.changeHideBalanceState();
          },
          iconSize: 16,
          color: ColorsTheme.of(context).iconPrimary,
          iconFillColor: Colors.transparent,
        )
      ],
    );
  }
}
