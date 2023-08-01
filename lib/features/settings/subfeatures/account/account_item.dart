import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'portrait.dart';

class AccountItem extends StatelessWidget {
  const AccountItem({
    super.key,
    required this.name,
    this.mns,
    required this.address,
    this.isSelected = false,
  });

  final String name;
  final String? mns;
  final String address;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
      child: Row(
        children: [
          Portrait(name: mns ?? address),
          const SizedBox(width: Sizes.spaceNormal),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: FontTheme.of(context).body2.secondary(),
              ),
              Text(
                Formatter.formatWalletAddress(address, nCharacters: 10),
                style: FontTheme.of(context).body1.primary(),
              ),
            ],
          ),
          const Spacer(),
          if (isSelected) ...[
            const Icon(Icons.check_rounded)
          ]
        ],
      ),
    );
  }
}
