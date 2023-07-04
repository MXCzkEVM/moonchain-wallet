import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../../../common/common.dart';
import '../../home_page_presenter.dart';

class BalancePanel extends HookConsumerWidget {
  const BalancePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(homeContainer.actions);
    final state = ref.watch(homeContainer.state);
    return GreyContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getBalanceDetails(context, state.walletBalance, presenter),
            state.walletBalance == '0.0'
                ? Container()
                : getBalanceChange(context),
            const SizedBox(
              height: 12,
            ),
            Divider(
              color: ColorsTheme.of(context).primaryBackground,
            ),
            getManagePortfolio(context)
          ],
        ));
  }

  Widget getBalanceDetails(
      BuildContext context, String balance, HomePresenter presenter) {
    String fractionalPart = "";
    String integerPart = balance;
    if (balance.contains('.')) {
      integerPart = balance.split('.')[0];
      fractionalPart = ".${balance.split('.')[1]}";
    }
    integerPart = Formatter.intThousandsSeparator(integerPart);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('${FlutterI18n.translate(context, 'balance')} ',
            style: FontTheme.of(context).h7().copyWith(
                fontSize: 16, color: ColorsTheme.of(context).secondaryText)),
        MxcCircleButton.icon(
          key: const Key("balanceHideButton"),
          icon: presenter.state.hideBalance ? MXCIcons.show : MXCIcons.hide,
          // textSpace: 0,
          shadowRadius: 20,
          onTap: () {
            presenter.changeHideBalanceState();
          },
          iconSize: 18,
          color: ColorsTheme.of(context).primaryText,
          iconFillColor: Colors.transparent,
        ),
        const Spacer(),
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: '$integerPart$fractionalPart',
              style: FontTheme.of(context).h5().copyWith(
                  fontWeight: FontWeight.w400,
                  foreground: presenter.state.hideBalance == true
                      ? (Paint()
                        ..style = PaintingStyle.fill
                        ..color = Colors.white
                        ..maskFilter =
                            const MaskFilter.blur(BlurStyle.normal, 6))
                      : null)),
          TextSpan(
              text: ' XSD',
              style: FontTheme.of(context).h5().copyWith(
                    color:
                        ColorsTheme.of(context).primaryText.withOpacity(0.32),
                    fontWeight: FontWeight.w400,
                  )),
        ])),
      ],
    );
  }

  Widget getBalanceChange(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          MXCIcons.increase,
          color: ColorsTheme.of(context).systemStatusActive,
          size: 16,
        ),
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: ' 28.20%',
              style: FontTheme.of(context)
                  .h7()
                  .copyWith(color: ColorsTheme.of(context).systemStatusActive)),
          TextSpan(
              text: '   ${FlutterI18n.translate(context, 'today')}',
              style: FontTheme.of(context).h7().copyWith(
                  color:
                      ColorsTheme.of(context).primaryText.withOpacity(0.32))),
        ]))
      ],
    );
  }

  Widget getManagePortfolio(BuildContext context) {
    return Row(
      children: [
        Icon(
          MXCIcons.coin,
          color: ColorsTheme.of(context).secondaryText,
        ),
        Text(
          '  Manage portfolio',
          style: FontTheme.of(context)
              .h7()
              .copyWith(fontWeight: FontWeight.w400, fontSize: 14),
        ),
        Spacer(),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: ColorsTheme.of(context).primaryText.withOpacity(0.32),
          size: 16,
        )
      ],
    );
  }
}
