import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class CustomerSupportButton extends StatelessWidget {
  const CustomerSupportButton(
      {required super.key,
      required this.title,
      required this.buttonLabel,
      required this.buttonFunction});

  final Function? buttonFunction;
  final String title;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: FontTheme.of(context).body2(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        MxcButton.secondary(
          key: key,
          title: buttonLabel,
          size: MXCWalletButtonSize.xl,
          edgeType: UIConfig.settingsScreensButtonsEdgeType,
          onTap: buttonFunction != null ? () => buttonFunction!() : null,
        ),
        const SizedBox(height: Sizes.spaceNormal),
      ],
    );
  }
}
