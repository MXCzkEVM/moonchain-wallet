import 'package:datadashwallet/common/utils/utils.dart';
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
    final state = ref.watch(openDAppPageContainer.state);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              ...tokenInfo(context, presenter, token),
            ],
          ),
        ),
        const SizedBox(height: 8),
        signButton(context),
      ],
    );
  }

  Widget signButton(BuildContext context) {
    String titleText = FlutterI18n.translate(context, 'add_x').replaceFirst(
        '{0}', FlutterI18n.translate(context, 'token').toLowerCase());
    AxsButtonType type = AxsButtonType.primary;

    return MxcButton.primary(
      key: const ValueKey('signButton'),
      size: AxsButtonSize.xl,
      title: titleText,
      type: type,
      onTap: () {
        if (onTap != null) onTap!();
        Navigator.of(context).pop(true);
      },
    );
  }

  List<Widget> tokenInfo(BuildContext context, OpenDAppPresenter presenter,
      WatchAssetModel token) {
    List<Widget> infoList = [];
    final contractAddress = token.contract;
    final symbol = token.symbol;
    final decimals = token.decimals;
    final decimalsString = decimals == null ? '--' : decimals.toString();

    infoList.add(buildInfoItem(context, presenter,
        FlutterI18n.translate(context, 'contract'), contractAddress ?? ''));
    infoList.add(buildInfoItem(context, presenter,
        FlutterI18n.translate(context, 'symbol'), symbol ?? ''));
    infoList.add(buildInfoItem(context, presenter,
        FlutterI18n.translate(context, 'decimals'), decimalsString));

    return infoList;
  }
}

Widget buildInfoItem(BuildContext context, OpenDAppPresenter presenter,
    String property, String value) {
  final isAddress = presenter.isAddress(value);
  return InfoItem(
    label: property,
    content: InkWell(
      onTap: isAddress ? () => presenter.launchAddress(value) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              value,
              style: FontTheme.of(context).body1.primary(),
              softWrap: true,
              textAlign: TextAlign.right,
            ),
          ),
          if (isAddress) ...[
            const SizedBox(width: 8),
            Icon(
              MxcIcons.external_link,
              size: 24,
              color: ColorsTheme.of(context).textSecondary,
            ),
          ]
        ],
      ),
    ),
  );
}

class InfoItem extends StatelessWidget {
  const InfoItem({
    Key? key,
    required this.label,
    required this.content,
  }) : super(key: key);

  final String label;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                FlutterI18n.translate(context, label),
                style: FontTheme.of(context).body1.secondary(),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }
}
