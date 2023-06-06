import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'splash_ens_query_presenter.dart';
import 'splash_ens_query_state.dart';

class SplashENSQueryPage extends HookConsumerWidget {
  const SplashENSQueryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashENSQueryContainer.actions);
    final state = ref.watch(splashENSQueryContainer.state);

    return MxcPage(
      layout: LayoutType.scrollable,
      useAppLinearBackground: true,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
      presenter: presenter,
      children: [
        const SizedBox(height: 50),
        Text(
          FlutterI18n.translate(context, 'choose_your_username'),
          style: FontTheme.of(context).h4.white(),
        ),
        const SizedBox(height: 32),
        Text(
          FlutterI18n.translate(context, 'ens_register_description'),
          style: FontTheme.of(context).caption1.white(),
        ),
        const SizedBox(height: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              FlutterI18n.translate(context, 'username'),
              style: FontTheme.of(context).caption2.white(),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: ColorsTheme.of(context).white),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: TextField(
                  controller: state.usernameController,
                  autofocus: true,
                  style: FontTheme.of(context).body1.white(),
                  decoration: InputDecoration(
                    constraints: const BoxConstraints(maxHeight: 36),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        '.mxc',
                        style: FontTheme.of(context).body1.white(),
                      ),
                    ),
                  ),
                  onChanged: (vlaue) => presenter.queryNameAvailable(),
                ),
              ),
            ),
            Text(
              FlutterI18n.translate(context, 'prowerd_zkevm'),
              style: FontTheme.of(context).caption1.white(),
            ),
          ],
        ),
        const SizedBox(height: 150),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MxcFullRoundedButton(
                key: const ValueKey('claimMyUsernameButton'),
                title: FlutterI18n.translate(context, 'claim_my_username'),
                onTap: state.isRegistered
                    ? () => presenter.claim()
                    : null,
              ),
              const SizedBox(height: 21),
              InkWell(
                key: const ValueKey('skipBiometrics'),
                child: Text(
                  FlutterI18n.translate(context, 'maybe_later'),
                  style: FontTheme.of(context).body2.white(),
                ),
                onTap: () => Navigator.of(context)
                    .replaceAll(route(const HomeMainPage())),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
