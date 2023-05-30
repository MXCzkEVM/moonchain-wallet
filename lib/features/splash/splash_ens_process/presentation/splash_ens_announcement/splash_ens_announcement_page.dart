import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/security/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'splash_ens_announcement_page_presenter.dart';
import 'splash_ens_announcement_page_state.dart';

class SplashENSAnnouncementPage extends HookConsumerWidget {
  const SplashENSAnnouncementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashENSAnnouncementPageContainer.actions);

    return MxcPage(
      layout: LayoutType.scrollable,
      useAppLinearBackground: true,
      presenter: presenter,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextField(
                maxLines: 7,
                style: FontTheme.of(context).body1.white(),
                decoration: InputDecoration(
                  hintText:
                      FlutterI18n.translate(context, 'mnemonic_passphrase'),
                  focusedBorder: InputBorder.none,
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 150,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 72),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MxcFullRoundedButton(
                key: const ValueKey('claimButton'),
                title: FlutterI18n.translate(context, 'claim').toUpperCase(),
                onTap: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
