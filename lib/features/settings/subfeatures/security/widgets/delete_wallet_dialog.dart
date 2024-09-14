import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

Future<bool?> showDeleteWalletDialog({
  required BuildContext context,
  required String title,
  required TextEditingController controller,
  String? hint,
  String? cancel,
  String? ok,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      bool isButtonDisabled = false;
      return StatefulBuilder(
        builder: (_, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            backgroundColor: ColorsTheme.of(context).cardBackground,
            icon: Icon(
              Icons.warning_rounded,
              color: ColorsTheme.of(context).buttonCritical,
              size: 56,
            ),
            title: Text(
              FlutterI18n.translate(context, title),
              style: FontTheme.of(context).h6().copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            contentPadding: const EdgeInsets.only(
              top: Sizes.spaceSmall,
              bottom: Sizes.space2XLarge,
              left: Sizes.spaceNormal,
              right: Sizes.spaceNormal,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MxcTextField(
                    key: const ValueKey('typeTextfield'),
                    controller: controller,
                    hint: hint,
                    onChanged: (value) {
                      if (controller.text == 'yes') {
                        setState(
                          () {
                            isButtonDisabled = true;
                          },
                        );
                      } else {
                        setState(
                          () {
                            isButtonDisabled = false;
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: Sizes.spaceLarge),
                  MxcButton.primaryWarning(
                    key: const ValueKey('deleteButton'),
                    title:
                        FlutterI18n.translate(context, ok ?? 'delete_wallet'),
                    titleColor: ColorsTheme.of(context).textBlack200,
                    size: MXCWalletButtonSize.xl,
                    edgeType: UIConfig.settingsScreensButtonsEdgeType,
                    onTap: isButtonDisabled == true
                        ? () =>
                            Navigator.of(context).pop(controller.text == 'yes')
                        : null,
                  ),
                  const SizedBox(height: Sizes.spaceNormal),
                  MxcButton.secondary(
                    key: const ValueKey('cancelButton'),
                    title: FlutterI18n.translate(context, cancel ?? 'cancel'),
                    size: MXCWalletButtonSize.xl,
                    edgeType: UIConfig.settingsScreensButtonsEdgeType,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
