import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'portrait.dart';

class AccountItem extends StatelessWidget {
  const AccountItem(
      {super.key,
      required this.account,
      this.isSelected = false,
      this.onSelect,
      required this.isCustom,
      this.onRemove});

  final Account account;
  final bool isSelected;
  final VoidCallback? onSelect;
  final Function(Account)? onRemove;

  /// Imported
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.spaceSmall),
        child: Row(
          children: [
            Portrait(name: account.address),
            const SizedBox(width: Sizes.spaceNormal),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${FlutterI18n.translate(context, 'account')} ${account.name}',
                  style: FontTheme.of(context).body2.secondary(),
                ),
                const SizedBox(height: Sizes.space2XSmall),
                Text(
                  account.mns ??
                      Formatter.formatWalletAddress(account.address,
                          nCharacters: 10),
                  style: FontTheme.of(context).body1.primary(),
                ),
                const SizedBox(height: Sizes.space2XSmall),
                if (isCustom)
                  MxcChipButton(
                      key: const Key('importedChip'),
                      onTap: () {},
                      title: FlutterI18n.translate(context, 'imported'))
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_rounded),
            if (isCustom)
              IconButton(
                key: const Key('removeImportedAccountButton'),
                icon: Icon(Icons.delete,
                    size: 24, color: ColorsTheme.of(context).iconPrimary),
                onPressed: () => onRemove!(account),
              )
          ],
        ),
      ),
    );
  }
}
