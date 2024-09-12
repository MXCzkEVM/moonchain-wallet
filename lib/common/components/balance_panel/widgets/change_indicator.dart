import 'package:moonchain_wallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class ChangeIndicator extends HookConsumerWidget {
  const ChangeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(walletContainer.actions);
    final state = ref.watch(walletContainer.state);
    return state.changeIndicator != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              state.changeIndicator == 0.0
                  ? state.hideBalance == true
                      ? Container()
                      : Text(
                          '≈',
                          style: FontTheme.of(context).caption1().copyWith(
                              fontWeight: FontWeight.w500,
                              color: ColorsTheme.of(context).textSecondary),
                        )
                  : state.hideBalance == true
                      ? Container()
                      : Icon(
                          state.changeIndicator!.isNegative
                              ? MxcIcons.decrease
                              : MxcIcons.increase,
                          color: state.changeIndicator!.isNegative
                              ? ColorsTheme.of(context).saturatedRed
                              : ColorsTheme.of(context).systemStatusActive,
                          size: 16,
                        ),
              const SizedBox(
                width: 4,
              ),
              Text(
                '${state.changeIndicator == 0.0 ? 0 : state.changeIndicator!.toStringAsFixed(2)}%',
                style: FontTheme.of(context).h7().copyWith(
                      foreground: state.hideBalance == true
                          ? (Paint()
                            ..style = PaintingStyle.fill
                            ..color = Colors.white
                            ..maskFilter =
                                const MaskFilter.blur(BlurStyle.normal, 6))
                          : null,
                      color: state.hideBalance == true
                          ? null
                          : state.changeIndicator == 0.0
                              ? ColorsTheme.of(context).textSecondary
                              : state.changeIndicator!.isNegative
                                  ? ColorsTheme.of(context).saturatedRed
                                  : ColorsTheme.of(context).systemStatusActive,
                    ),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                FlutterI18n.translate(context, 'today'),
                style: FontTheme.of(context)
                    .caption1()
                    .copyWith(color: ColorsTheme.of(context).textSecondary),
              ),
            ],
          )
        : Container();
  }
}
