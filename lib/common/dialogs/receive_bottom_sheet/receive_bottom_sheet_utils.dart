import 'package:moonchain_wallet/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

void showReceiveBottomSheet(
    BuildContext context,
    String walletAddress,
    int chainId,
    String networkSymbol,
    VoidCallback onL3Tap,
    void Function(String url) launchUrlInPlatformDefault,
    bool showError) {
  if (MXCChains.isMXCChains(chainId)) {
    showWalletAddressDialogMXCChains(
        context: context,
        walletAddress: walletAddress,
        onL3Tap: () => onL3Tap(),
        launchUrlInPlatformDefault: launchUrlInPlatformDefault,
        showError: showError);
  } else {
    showWalletAddressDialogOtherChains(
        context: context,
        walletAddress: walletAddress,
        networkSymbol: networkSymbol,
        showError: showError);
  }
}

void showWalletAddressDialogMXCChains(
        {required BuildContext context,
        required String walletAddress,
        required VoidCallback onL3Tap,
        required Function(String) launchUrlInPlatformDefault,
        required bool showError}) =>
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
        ],
        showError: showError);

void showWalletAddressDialogOtherChains(
        {required BuildContext context,
        required String walletAddress,
        required String networkSymbol,
        required bool showError}) =>
    showWalletAddressDialog(
        context: context,
        walletAddress: walletAddress,
        noticeComponents: [
          BlackBox(
              child: applyTextStyle(
                  context, buySomeXForFeeNotice(context, networkSymbol)))
        ],
        showError: showError);

void showWalletAddressDialogSimple(
        {required BuildContext context,
        required String walletAddress,
        required bool showError}) =>
    showWalletAddressDialog(
        context: context,
        walletAddress: walletAddress,
        noticeComponents: [],
        showError: showError);

void showWalletAddressDialog(
    {required BuildContext context,
    required String walletAddress,
    required List<Widget> noticeComponents,
    required bool showError}) {
  showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => ReceiveBottomSheet(
      walletAddress: walletAddress,
      noticeComponents: noticeComponents,
      showError: showError,
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
