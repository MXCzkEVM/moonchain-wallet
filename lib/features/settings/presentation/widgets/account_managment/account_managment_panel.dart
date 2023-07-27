import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'copyable_item.dart';

class AccountManagementPanel extends HookConsumerWidget {
  const AccountManagementPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(settingsContainer.actions);
    final state = ref.watch(settingsContainer.state);
    final walletAddress =
        Formatter.formatWalletAddress(state.walletAddress!, nCharacters: 10);

    return GreyContainer(
        padding: const EdgeInsetsDirectional.only(
            bottom: Sizes.spaceSmall,
            top: Sizes.spaceSmall,
            start: Sizes.spaceNormal,
            end: Sizes.spaceSmall),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  state.accountName ?? 'Acount 1',
                  style: FontTheme.of(context).body2.primary(),
                ),
                const Spacer(),
                Icon(
                  MXCIcons.dropdown_down,
                  size: 24,
                  color: ColorsTheme.of(context).iconPrimary,
                )
              ],
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
                    state.name != null
                        ? CopyableItem(
                            text: state.name!,
                            copyableText: state.name!,
                          )
                        : Container(),
                    const SizedBox(
                      height: 8,
                    ),
                    CopyableItem(
                      text: walletAddress,
                      copyableText: state.walletAddress!,
                    ),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).push(route(QrCodePage(
                    name: state.name,
                    address: state.walletAddress,
                  ))),
                  child: Container(
                    padding: const EdgeInsets.all(Sizes.spaceXSmall),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorsTheme.of(context).backgroundGrey6),
                    child: Icon(
                      MXCIcons.qr_code,
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
