import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

void showReceiveBottomSheet(
    BuildContext context,
    String walletAddress,
    int chainId,
    String networkSymbol,
    VoidCallback onL3Tap,
    void Function(String url) launchUrlInPlatformDefault) {
  if (Config.isMxcChains(chainId)) {
    showWalletAddressDialogMXCChains(
        context: context,
        walletAddress: walletAddress,
        onL3Tap: () => onL3Tap(),
        launchUrlInPlatformDefault: launchUrlInPlatformDefault);
  } else {
    showWalletAddressDialogOtherChains(
        context: context,
        walletAddress: walletAddress,
        networkSymbol: networkSymbol);
  }
}

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
    builder: (BuildContext context) => ReceiveBottomSheet(
      walletAddress: walletAddress,
      noticeComponents: noticeComponents,
    ),
  );
}

Widget applyTextStyle(BuildContext context, List<TextSpan> children) {
  return RichText(
    text: TextSpan(
      style: FontTheme.of(context, listen: false).body1.primary(),
      children: [...children],
    ),
  );
}
