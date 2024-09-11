import 'package:moonchain_wallet/common/components/list/single_line_info_item.dart';
import 'package:moonchain_wallet/common/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../open_dapp_presenter.dart';

class AddAssetInfo extends ConsumerWidget {
  const AddAssetInfo({
    Key? key,
    required this.token,
    this.onTap,
  }) : super(key: key);

  final WatchAssetModel token;
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
              ...tokenInfo(context, token),
            ],
          ),
        ),
        const SizedBox(height: 8),
        addTokenButton(context),
      ],
    );
  }

  Widget addTokenButton(BuildContext context) {
    String titleText = FlutterI18n.translate(context, 'add_x').replaceFirst(
        '{0}', FlutterI18n.translate(context, 'token').toLowerCase());
    MXCWalletButtonType type = MXCWalletButtonType.primary;

    return MxcButton.primary(
      key: const ValueKey('addTokenButton'),
      size: MXCWalletButtonSize.xl,
      title: titleText,
      type: type,
      onTap: () {
        if (onTap != null) onTap!();
        Navigator.of(context).pop(true);
      },
    );
  }

  List<Widget> tokenInfo(BuildContext context, WatchAssetModel token) {
    List<Widget> infoList = [];
    final contractAddress = token.contract;
    final symbol = token.symbol;
    final decimals = token.decimals;
    final decimalsString = decimals == null ? '--' : decimals.toString();

    infoList.add(SingleLineInfoItem(
        title: FlutterI18n.translate(context, 'contract'),
        value: contractAddress ?? ''));
    infoList.add(SingleLineInfoItem(
      title: FlutterI18n.translate(context, 'symbol'),
      value: symbol ?? '',
    ));
    infoList.add(SingleLineInfoItem(
        title: FlutterI18n.translate(context, 'decimals'),
        value: decimalsString));

    return infoList;
  }
}
