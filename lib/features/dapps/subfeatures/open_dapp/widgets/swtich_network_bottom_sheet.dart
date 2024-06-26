import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'transaction_info.dart';

enum TransactionProcessType { confirm, send, sending, done }

Future<bool?> showSwitchNetworkDialog(
  BuildContext context, {
  required String fromNetwork,
  required String toNetwork,
  required void Function() onTap,
}) {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => Container(
      padding: const EdgeInsets.only(
          top: Sizes.spaceNormal, bottom: Sizes.space3XLarge),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).layerSheetBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: Sizes.spaceXLarge,
        ),
        child: Column(
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
              style: FontTheme.of(context).body2.primary(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: Sizes.spaceXLarge,
            ),
            MxcButton.secondary(
              key: const ValueKey('cancelButton'),
              title: translate('cancel'),
              onTap: () => Navigator.of(context).pop(false),
              size: AxsButtonSize.xl,
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
              size: AxsButtonSize.xl,
            ),
            const SizedBox(height: Sizes.spaceNormal)
          ],
        ),
      ),
    ),
  );
}
