import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/secured_storage/secured_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'login_page_presentater.dart';

class LoginPage extends ConsumerWidget with SplashScreenMixin {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MxcPage(
      layout: LayoutType.column,
      useAppLinearBackground: true,
      presenter: ref.watch(loginPageContainer.actions),
      children: [
        Expanded(
          child: appLogo(context),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MxcFullRoundedButton(
                  key: const ValueKey('createButton'),
                  title: FlutterI18n.translate(context, 'create_wallet'),
                  onTap: () => Navigator.of(context).push(
                    route(
                      const SecuredStoragePage(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 28,
                ),
                MxcFullRoundedButton(
                  key: const ValueKey('importButton'),
                  title: FlutterI18n.translate(context, 'import_wallet'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
