import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../open_dapp_presenter.dart';

class TypeMessageInfo extends ConsumerWidget {
  const TypeMessageInfo({
    Key? key,
    required this.networkName,
    required this.primaryType,
    required this.message,
    this.onTap,
  }) : super(key: key);

  final String networkName;
  final String primaryType;
  final Map<String, dynamic> message;
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
              ...infoItems(context, presenter),
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
    AxsButtonType type = AxsButtonType.primary;

    return MxcButton.primary(
      key: const ValueKey('signButton'),
      size: AxsButtonSize.xl,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryType,
              style: FontTheme.of(context).h5(),
              softWrap: true,
              textAlign: TextAlign.start,
            ),
            const Spacer(),
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

  List<Widget> infoItems(BuildContext context, OpenDAppPresenter presenter) {
    final List<Widget> infoList = <Widget>[];
    final keyList = message.keys.toList();
    final valueList = message.values.toList();
    for (int i = 0; i < keyList.length; i++) {
      final property = keyList[i];
      final value = valueList[i].toString();
      infoList.add(SingleLineInfoItem(title: property, value: value));
    }
    return infoList;
  }
}
