import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'app_nav_bar_presenter.dart';
import 'app_nav_bar_state.dart';

class AppNavBar extends HookConsumerWidget {
  const AppNavBar({Key? key, this.leading, this.action, this.title})
      : super(key: key);

  final Widget? leading;
  final Widget? action;
  final Widget? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(appNavBarContainer.actions);
    final state = ref.watch(appNavBarContainer.state);

    return PresenterHooks(
      presenter: presenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (leading == null) ...[
              IconButton(
                key: const ValueKey('backButton'),
                icon: const Icon(Icons.arrow_back_rounded),
                iconSize: 32,
                onPressed: appBarPopHandlerBuilder(context),
                color: ColorsTheme.of(context).iconPrimary,
              ),
            ] else ...[
              leading!,
            ],
            if (title == null) ...[
              Container(
                padding: const EdgeInsets.all(Sizes.space2XSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: ColorsTheme.of(context).iconPrimary,
                ),
                child: GestureDetector(
                  onTap: () => presenter.copy(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Portrait(
                        name: state.account?.address ?? '',
                      ),
                      const SizedBox(width: Sizes.space2XSmall),
                      Text(
                        state.account?.mns ??
                            MXCFormatter.formatWalletAddress(
                                state.account?.address ?? ''),
                        style: FontTheme.of(context).subtitle1().copyWith(
                              color: ColorsTheme.of(context).screenBackground,
                            ),
                      )
                    ],
                  ),
                ),
              ),
            ] else ...[
              title!
            ],
            if (action == null) ...[
              const SizedBox(width: 32),
            ] else ...[
              action!,
            ]
          ],
        ),
      ),
    );
  }
}
