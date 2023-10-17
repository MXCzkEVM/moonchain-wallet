import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/presentation/passcode_authenticate/passcode_authenticate_user_page.dart';
import 'package:datadashwallet/features/settings/presentation/widgets/account_managment/copyable_item.dart';
import 'package:datadashwallet/features/settings/subfeatures/accounts/show_view_private_key_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../presentation/settings_page_presenter.dart';
import '../qr_scanner/qr_scanner_page.dart';

class QrCodePage extends HookConsumerWidget {
  const QrCodePage(
      {Key? key, this.name, this.address, required this.privateKey})
      : super(key: key);

  final String? name;
  final String? address;
  final String privateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(settingsContainer.actions);
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      crossAxisAlignment: CrossAxisAlignment.center,
      appBar: MxcAppBarEvenly.back(
        titleText: translate('qr_code'),
        useContentPadding: true,
      ),
      children: [
        Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            color: ColorsTheme.of(context).primaryBackground,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: Sizes.space6XLarge),
          child: Column(
            children: [
              if (name != null)
                CopyableItem(
                  text: name!,
                  copyableText: name!,
                ),
              const SizedBox(height: Sizes.spaceXSmall),
              if (address != null)
                CopyableItem(
                  text:
                      Formatter.formatWalletAddress(address!, nCharacters: 10),
                  copyableText: address!,
                ),
              const SizedBox(height: Sizes.spaceXLarge),
              QrImageView(
                data: address ?? '',
                size: 160,
                dataModuleStyle: QrDataModuleStyle(
                    color: ColorsTheme.of(context).textPrimary,
                    dataModuleShape: QrDataModuleShape.square),
                eyeStyle: QrEyeStyle(
                    color: ColorsTheme.of(context).textPrimary,
                    eyeShape: QrEyeShape.square),
              ),
            ],
          ),
        ),
        MxcButton.secondary(
          key: const ValueKey('viewPrivateKeyButton'),
          title: FlutterI18n.translate(context, 'view_private_key'),
          onTap: () => Navigator.of(context)
              .push(
            route.featureDialog<PasscodeAuthenticateUserPage>(
                const PasscodeAuthenticateUserPage(
              dismissedDest: 'QrCodePage',
            )),
          )
              .then((value) {
            if (value == true) {
              showViewPrivateKeyDialog(
                  context: context,
                  privateKey: privateKey,
                  onCopy: presenter.copyToClipboard);
            }
          }),
        ),
        const SizedBox(height: Sizes.space5XLarge),
        MxcButton.primary(
          key: const ValueKey('scanQrCodeButton'),
          title: FlutterI18n.translate(context, 'scan_qr_code'),
          icon: MxcIcons.qr_code,
          onTap: () => Navigator.of(context).push(
            route.featureDialog(const QrScannerPage()),
          ),
        ),
      ],
    );
  }
}
