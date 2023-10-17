import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
      child: Container(
        padding: const EdgeInsets.only(
            left: 16, right: 16, top: 0, bottom: Sizes.space3XLarge),
        decoration: BoxDecoration(
          color: ColorsTheme.of(context).screenBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
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
                    isSelected:
                        currentAccount.address == accounts[index].address,
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
              size: AxsButtonSize.xl,
            ),
            const SizedBox(height: Sizes.spaceXSmall),
            MxcButton.plainWhite(
              key: const ValueKey('importAccountButton'),
              title: FlutterI18n.translate(context, 'import_account'),
              onTap: onImport,
              size: AxsButtonSize.xl,
              titleColor: ColorsTheme.of(context).primary,
            ),
          ],
        ),
      ),
    ),
  );
}
