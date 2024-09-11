import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showAutoClaimExecutionAlertDialog(
    {required BuildContext context, required Function executeAutoClaim}) async {
  String translate(String text) => FlutterI18n.translate(context, text);

  return showBaseBottomSheet<bool>(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxcAppBarEvenly.title(
          titleText: translate('auto_claim_execution_dialog_title'),
          useContentPadding: false,
          textFieldFlex: 5,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: Sizes.spaceXLarge,
          ),
          child: Column(
            children: [
              Text(
                translate(
                  'auto_claim_execution_dialog_text',
                ),
                style: FontTheme.of(context, listen: false)
                    .body1
                    .primary()
                    .copyWith(),
                softWrap: true,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: Sizes.spaceNormal,
              ),
              MxcButton.secondary(
                key: const ValueKey('cancelButton'),
                title: translate('cancel'),
                onTap: () => Navigator.of(context).pop(false),
                size: MXCWalletButtonSize.xl,
              ),
              const SizedBox(
                height: Sizes.spaceNormal,
              ),
              MxcButton.primary(
                key: const ValueKey('executeButton'),
                title: translate('execute'),
                onTap: () {
                  executeAutoClaim();
                  Navigator.of(context).pop(true);
                },
                size: MXCWalletButtonSize.xl,
              ),
            ],
          ),
        )
      ],
    ),
  );
}
