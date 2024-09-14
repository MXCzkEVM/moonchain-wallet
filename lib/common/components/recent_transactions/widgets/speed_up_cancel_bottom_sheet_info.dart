import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

class SpeedUpCancelBottomSheetInfo extends ConsumerWidget {
  const SpeedUpCancelBottomSheetInfo(
      {Key? key,
      required this.estimatedFee,
      required this.maxFee,
      required this.symbol})
      : super(key: key);

  final String estimatedFee;
  final String maxFee;
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...notice(context),
              SingleLineInfoItem(
                title: 'estimated_fee',
                value: MXCFormatter.formatNumberForUI(
                  estimatedFee,
                ),
                hint: symbol,
              ),
              SingleLineInfoItem(
                title: 'max_fee',
                value: MXCFormatter.formatNumberForUI(
                  maxFee,
                ),
                hint: symbol,
              ),
            ],
          ),
        ),
        const SizedBox(height: Sizes.spaceXSmall),
        submitButton(context),
      ],
    );
  }

  Widget submitButton(BuildContext context) {
    String titleText = 'submit';
    MXCWalletButtonType type = MXCWalletButtonType.primary;

    return MxcButton.primary(
      key: const ValueKey('submitButton'),
      size: MXCWalletButtonSize.xl,
      title: FlutterI18n.translate(context, titleText),
      type: type,
      onTap: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  List<Widget> notice(BuildContext context) {
    return [
      Text(
        FlutterI18n.translate(context, 'gas_fee_replacement_notice'),
        style: FontTheme.of(context).subtitle1.primary(),
      ),
      const SizedBox(
        height: Sizes.spaceXSmall,
      ),
    ];
  }
}
