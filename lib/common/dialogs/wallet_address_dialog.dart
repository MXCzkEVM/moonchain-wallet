import 'dart:ui';

import 'package:clipboard/clipboard.dart';
import 'package:datadashwallet/common/urls.dart';
import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/src/providers/providers_use_cases.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Provide onL3Tap for MXC Chains And networkSymbol for other chains

void showWalletAddressDialogMXCChains(
        {required BuildContext context,
        required String walletAddress,
        required VoidCallback onL3Tap,
        required Function(String) launchUrlInPlatformDefault}) =>
    showWalletAddressDialog(
        context: context,
        walletAddress: walletAddress,
        noticeComponents: [
          BlackBox(
              child: applyTextStyle(
                  context,
                  depositFromExchangesNotice(
                      context, launchUrlInPlatformDefault))),
          BlackBox(
              child: applyTextStyle(
                  context, depositWithL3BridgeNotice(context, onL3Tap))),
        ]);

void showWalletAddressDialogOtherChains(
        {required BuildContext context,
        required String walletAddress,
        required String networkSymbol}) =>
    showWalletAddressDialog(
        context: context,
        walletAddress: walletAddress,
        noticeComponents: [
          BlackBox(
              child: applyTextStyle(
                  context, buySomeXForFeeNotice(context, networkSymbol)))
        ]);

void showWalletAddressDialogSimple({
  required BuildContext context,
  required String walletAddress,
}) =>
    showWalletAddressDialog(
        context: context, walletAddress: walletAddress, noticeComponents: []);

void showWalletAddressDialog(
    {required BuildContext context,
    required String walletAddress,
    required List<Widget> noticeComponents}) {
  showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => WalletAddressBottomSheet(
      walletAddress: walletAddress,
      noticeComponents: noticeComponents,
    ),
  );
}

class WalletAddressBottomSheet extends HookConsumerWidget {
  const WalletAddressBottomSheet(
      {Key? key, this.walletAddress, required this.noticeComponents})
      : super(key: key);

  final String? walletAddress;
  final List<Widget> noticeComponents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedWalletAddress =
        Formatter.formatWalletAddress(walletAddress ?? '');
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

class BlackBox extends StatelessWidget {
  const BlackBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsTheme.of(context).grey6,
        borderRadius: const BorderRadius.all(Radius.circular(35)),
      ),
      child: child,
    );
  }
}

Widget applyTextStyle(BuildContext context, List<TextSpan> children) {
  return RichText(
    text: TextSpan(
      style: FontTheme.of(context, listen: false).body1.primary(),
      children: [...children],
    ),
  );
}

List<TextSpan> depositFromExchangesNotice(
    BuildContext context, void Function(String) launchUrl) {
  final text = FlutterI18n.translate(context, 'deposit_from_exchanges_notice');
  final firstSplit = text.split('{0}');
  final firstPart = firstSplit[0];
  final secondSplit = firstSplit[1].split('{1}');
  final secondPart = secondSplit[0];
  final thirdPart = secondSplit[1];
  return [
    TextSpan(
      text: firstPart,
    ),
    TextSpan(
      text: 'OKX',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.okx);
        },
    ),
    TextSpan(text: secondPart),
    TextSpan(
      text: 'Gate.io',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          launchUrl(Urls.gateio);
        },
    ),
    TextSpan(text: thirdPart),
  ];
}

List<TextSpan> depositWithL3BridgeNotice(
  BuildContext context,
  VoidCallback onL3Tap,
) {
  final text = FlutterI18n.translate(context, 'deposit_with_l3_bridge_notice');
  final firstSplit = text.split('{0}');
  final firstPart = firstSplit[0];
  final secondPart = firstSplit[1];
  return [
    TextSpan(
      text: firstPart,
    ),
    TextSpan(
      text: 'L3 bridge',
      style: TextStyle(
        color: ColorsTheme.of(context, listen: false).textSecondary,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = onL3Tap,
    ),
    TextSpan(text: secondPart),
  ];
}

List<TextSpan> buySomeXForFeeNotice(
    BuildContext context, String networkSymbol) {
  String text = FlutterI18n.translate(context, 'buy_some_x_for_fee_notice');
  text = text.replaceFirst('{0}', networkSymbol);
  return [
    TextSpan(
      text: text,
    ),
  ];
}
