import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../open_dapp_presenter.dart';

class MessageInfo extends ConsumerWidget {
  const MessageInfo({
    Key? key,
    required this.networkName,
    required this.message,
    this.onTap,
  }) : super(key: key);

  final String networkName;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(openDAppPageContainer.actions);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              titleItem(context),
              messageItem(context, presenter, message),
            ],
          ),
        ),
        const SizedBox(height: 8),
        signButton(context),
      ],
    );
  }

  Widget signButton(BuildContext context) {
    String titleText = 'sign';
    MXCWalletButtonType type = MXCWalletButtonType.primary;

    return MxcButton.primary(
      key: const ValueKey('signButton'),
      size: MXCWalletButtonSize.xl,
      title: FlutterI18n.translate(context, titleText),
      type: type,
      onTap: () {
        if (onTap != null) onTap!();
        Navigator.of(context).pop(true);
      },
    );
  }

  Widget titleItem(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              networkName,
              style: FontTheme.of(context).body2.secondary(),
              softWrap: true,
            ),
            const SizedBox(height: 4),
          ],
        )
      ],
    );
  }

  Widget messageItem(
      BuildContext context, OpenDAppPresenter presenter, String message) {
    return SingleLineInfoItem(
      title: FlutterI18n.translate(context, 'message'),
      value: message,
      valueAlign: TextAlign.start,
    );
  }
}
