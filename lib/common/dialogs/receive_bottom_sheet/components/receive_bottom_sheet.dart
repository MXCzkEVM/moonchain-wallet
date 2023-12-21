import 'dart:ui';

import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveBottomSheet extends StatelessWidget {
  const ReceiveBottomSheet(
      {Key? key,
      this.walletAddress,
      required this.noticeComponents,
      required this.showError})
      : super(key: key);

  final String? walletAddress;
  final List<Widget> noticeComponents;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final formattedWalletAddress =
        MXCFormatter.formatWalletAddress(walletAddress ?? '');
    bool isWalletAddressCopied = false;

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 20,
        sigmaY: 20,
      ),
      child: Container(
        padding: const EdgeInsets.only(right: 24, left: 24, bottom: 44),
        decoration: BoxDecoration(
          color: ColorsTheme.of(context).cardBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxcAppBarEvenly.title(
              titleText: FlutterI18n.translate(context, 'receive'),
              action: Container(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: const Icon(Icons.close),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
            ),
            if (showError)
              Text(
                FlutterI18n.translate(context, 'insufficient_funds_notice'),
                style: FontTheme.of(context).body1.error(),
                textAlign: TextAlign.center,
              ),
            QrImageView(
              data: walletAddress ?? '',
              size: 215,
              dataModuleStyle: QrDataModuleStyle(
                  color: ColorsTheme.of(context).textPrimary,
                  dataModuleShape: QrDataModuleShape.square),
              eyeStyle: QrEyeStyle(
                  color: ColorsTheme.of(context).textPrimary,
                  eyeShape: QrEyeShape.square),
            ),
            const SizedBox(height: 16),
            Text(
              FlutterI18n.translate(context,
                  'scan_or_copy_address_below_to_receive_tokens_or_nfts'),
              style: FontTheme.of(context).body1.secondary(),
              textAlign: TextAlign.center,
            ),
            BlackBox(
              child: StatefulBuilder(builder: (_, setState) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedWalletAddress,
                        style: FontTheme.of(context).subtitle1.primary(),
                      ),
                      MxcChipButton(
                        key: const Key('copyButton'),
                        onTap: () async {
                          await FlutterClipboard.copy(walletAddress ?? '');
                          setState(() => isWalletAddressCopied = true);
                        },
                        title: isWalletAddressCopied
                            ? FlutterI18n.translate(context, 'copied')
                            : FlutterI18n.translate(context, 'copy_address'),
                        iconData: Icons.check_circle_rounded,
                        iconSize: 16,
                        alignIconStart: true,
                        iconColor: isWalletAddressCopied
                            ? ColorsTheme.of(context).iconBlack200
                            : ColorsTheme.of(context).iconPrimary,
                        textStyle: isWalletAddressCopied
                            ? FontTheme.of(context).subtitle1().copyWith(
                                color: ColorsTheme.of(context).textBlack200)
                            : FontTheme.of(context).subtitle1.primary(),
                        backgroundColor: isWalletAddressCopied
                            ? ColorsTheme.of(context).systemStatusActive
                            : null,
                      )
                    ]);
              }),
            ),
            ...noticeComponents
          ],
        ),
      ),
    );
  }
}
