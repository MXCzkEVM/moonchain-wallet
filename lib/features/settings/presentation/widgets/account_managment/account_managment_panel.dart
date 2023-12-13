import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:datadashwallet/features/settings/subfeatures/accounts/show_accounts_dialog.dart';
import 'package:datadashwallet/features/settings/subfeatures/accounts/subfeatures/import_account/import_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'copyable_item.dart';

class AccountManagementPanel extends HookConsumerWidget {
  const AccountManagementPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(settingsContainer.actions);
    final state = ref.watch(settingsContainer.state);
    final account = state.account;
    final walletAddress = MXCFormatter.formatWalletAddress(
        account?.address ?? '',
        nCharacters: 10);

    return GreyContainer(
        padding: const EdgeInsetsDirectional.only(
            bottom: Sizes.spaceSmall,
            top: Sizes.spaceSmall,
            start: Sizes.spaceNormal,
            end: Sizes.spaceSmall),
        child: Column(
          children: [
            InkWell(
              onTap: () => showAccountsDialog(
                context: context,
                currentAccount: state.account!,
                accounts: state.accounts,
                isLoading: state.isLoading,
                onImport: () => Navigator.of(context).push(
                  route.featureDialog(
                    const ImportAccountPage(),
                  ),
                ),
                onAdd: () => presenter.addNewAccount(),
                onSelect: (item) => presenter.changeAccount(item),
                onRemove: (item) => presenter.removeAccount(item),
              ),
              child: Row(
                children: [
                  Portrait(
                    name: account!.address,
                  ),
                  const SizedBox(width: Sizes.space2XSmall),
                  Text(
                    '${FlutterI18n.translate(context, 'account')} ${account.name}',
                    style: FontTheme.of(context).body2.primary(),
                  ),
                  const Spacer(),
                  Icon(
                    MxcIcons.dropdown_down,
                    size: 24,
                    color: ColorsTheme.of(context).iconPrimary,
                  )
                ],
              ),
            ),
            Divider(
              color: ColorsTheme.of(context).grey3,
              height: Sizes.spaceXSmall * 2,
              thickness: 0.5,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    account.mns != null
                        ? CopyableItem(
                            text: account.mns!,
                            copyableText: account.mns!,
                          )
                        : Container(),
                    const SizedBox(
                      height: 8,
                    ),
                    CopyableItem(
                      text: walletAddress,
                      copyableText: account.address,
                    ),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).push(route(QrCodePage(
                    name: account.mns,
                    address: account.address,
                    privateKey: state.account?.privateKey ?? '',
                  ))),
                  child: Container(
                    padding: const EdgeInsets.all(Sizes.spaceXSmall),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorsTheme.of(context).backgroundGrey6),
                    child: Icon(
                      MxcIcons.qr_code,
                      size: 32,
                      color: ColorsTheme.of(context).iconPrimary,
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }
}
