import 'package:moonchain_wallet/common/bottom_sheets/bottom_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'account_item.dart';

void showAccountsDialog(
    {required BuildContext context,
    required Account currentAccount,
    required List<Account> accounts,
    bool isLoading = false,
    VoidCallback? onAdd,
    VoidCallback? onImport,
    required Function(Account) onSelect,
    required Function(Account) onRemove}) {
  showBaseBottomSheet<void>(
    context: context,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MxcAppBarEvenly.title(
          titleText: FlutterI18n.translate(context, 'accounts'),
          action: Container(
            alignment: Alignment.centerRight,
            child: InkWell(
              child: const Icon(Icons.close),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: accounts.length,
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              return AccountItem(
                account: accounts[index],
                isSelected: currentAccount.address == accounts[index].address,
                onSelect: () => onSelect(accounts[index]),
                isCustom: accounts[index].isCustom,
                onRemove: onRemove,
              );
            },
          ),
        ),
        const SizedBox(height: Sizes.spaceXSmall),
        MxcButton.primary(
          key: const ValueKey('addAccountButton'),
          title: FlutterI18n.translate(
              context, isLoading ? 'adding_account' : 'add_new_account'),
          onTap: onAdd,
          size: MXCWalletButtonSize.xl,
        ),
        const SizedBox(height: Sizes.spaceXSmall),
        MxcButton.plainWhite(
          key: const ValueKey('importAccountButton'),
          title: FlutterI18n.translate(context, 'import_account'),
          onTap: onImport,
          size: MXCWalletButtonSize.xl,
          titleColor: ColorsTheme.of(
            context,
            listen: false,
          ).primary,
        ),
      ],
    ),
  );
}
