import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

enum TransactionProcessType { confirm, send, sending, done }

Future<bool?> showSwitchNetworkDialog(
  BuildContext context, {
  required String fromNetwork,
  required String toNetwork,
  required void Function() onTap,
}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showBaseBottomSheet<bool>(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
              start: Sizes.spaceNormal,
              end: Sizes.spaceNormal,
              bottom: Sizes.space2XLarge),
          child: MxcAppBarEvenly.title(
            titleText: translate('switch_to_network'),
          ),
        ),
        Text(
          translate('allow_this_site_notice')
              .replaceFirst('{0}', "\"$fromNetwork\"")
              .replaceFirst('{1}', "\"$toNetwork\""),
          style: FontTheme.of(context, listen: false).body2.primary(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: Sizes.spaceXLarge,
        ),
        MxcButton.secondary(
          key: const ValueKey('cancelButton'),
          title: translate('cancel'),
          onTap: () => Navigator.of(context).pop(false),
          size: MXCWalletButtonSize.xl,
          edgeType: MXCWalletButtonEdgeType.hard,
        ),
        const SizedBox(
          height: Sizes.spaceXLarge,
        ),
        MxcButton.primary(
          key: const ValueKey('approveButton'),
          title: translate('approve'),
          onTap: () {
            onTap();
            Navigator.of(context).pop(true);
          },
          size: MXCWalletButtonSize.xl,
          edgeType: MXCWalletButtonEdgeType.hard,
        ),
        const SizedBox(height: Sizes.spaceNormal),
      ],
    ),
  );
}
