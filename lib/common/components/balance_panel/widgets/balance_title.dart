import 'package:moonchain_wallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../common.dart';

class BalanceTitle extends HookConsumerWidget {
  const BalanceTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    final state = ref.watch(walletContainer.state);
    return Row(
      children: [
        Text(FlutterI18n.translate(context, 'balance'),
            style: FontTheme.of(context)
                .body2()
                .copyWith(color: ColorsTheme.of(context).textSecondary)),
        const SizedBox(
          width: 4,
        ),
        MxcCircleButton.icon(
          key: const Key("balanceHideButton"),
          icon: state.hideBalance ? MxcIcons.show : MxcIcons.hide,
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
