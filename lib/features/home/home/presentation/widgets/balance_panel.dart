import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../../../common/common.dart';

class BalancePanel extends StatefulWidget {
  const BalancePanel({Key? key}) : super(key: key);

  @override
  State<BalancePanel> createState() => _BalancePanelState();
}

class _BalancePanelState extends State<BalancePanel> {
  @override
  Widget build(BuildContext context) {
    return GreyContainer(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Center(
                    child: Text(FlutterI18n.translate(context, 'balance'),
                        style: FontTheme.of(context).h7().copyWith(fontWeight: FontWeight.w300, height: 1.8)))),
            Expanded(flex: 2, child: getBalanceDetails()),
            Expanded(flex: 2, child: getBalancePanelButtons())
          ],
        ));
  }

  Widget getBalancePanelButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MxcCircleButton.icon(
            key: const Key('managePortfolio'),
            icon: MXCIcons.wallet,
            onTap: () {},
            title: FlutterI18n.translate(context, 'manage_portfolio'),
            color: ColorsTheme.of(context).primaryText,
            iconSize: 25,
            shadowRadius: 30,
            textSpace: 0,
            titleStyle: FontTheme.of(context).h8()),
        MxcCircleButton.icon(
            key: const Key('fiatOptions'),
            icon: MXCIcons.wallet,
            onTap: () {},
            title: FlutterI18n.translate(context, 'fiat_options'),
            color: ColorsTheme.of(context).primaryText,
            iconSize: 25,
            shadowRadius: 30,
            textSpace: 0,
            titleStyle: FontTheme.of(context).h8()),
        MxcCircleButton.icon(
            key: const Key('show/hideBalance'),
            icon: Icons.remove_red_eye_outlined,
            onTap: () {},
            title: FlutterI18n.translate(context, 'show/hide_balance'),
            color: ColorsTheme.of(context).primaryText,
            iconSize: 25,
            shadowRadius: 30,
            textSpace: 0,
            titleStyle: FontTheme.of(context).h8())
      ],
    );
  }

  Widget getBalanceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
            text: TextSpan(children: [
          TextSpan(text: '\$', style: FontTheme.of(context).h6().copyWith(fontWeight: FontWeight.w300, fontSize: 18, height: 0)),
          TextSpan(text: '18945', style: FontTheme.of(context).h6().copyWith(fontWeight: FontWeight.w300, fontSize: 18, height: 0)),
          TextSpan(
              text: '.34',
              style: FontTheme.of(context)
                  .h6()
                  .copyWith(color: ColorsTheme.of(context).secondaryText.withOpacity(0.3), fontWeight: FontWeight.w300, fontSize: 18, height: 0))
        ])),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              color: ColorsTheme.of(context).active,
              MXCIcons.loss,
              size: 14,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(text: '28.20%', style: FontTheme.of(context).h8().copyWith(color: ColorsTheme.of(context).active)),
              TextSpan(text: '   ${FlutterI18n.translate(context, 'today')}', style: FontTheme.of(context).h8().copyWith(color: ColorsTheme.of(context).secondaryText.withOpacity(0.5))),
            ]))
          ],
        ),
      ],
    );
  }
}
