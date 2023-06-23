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
import 'widgets/query_text_field.dart';

class SplashENSQueryPage extends HookConsumerWidget {
  const SplashENSQueryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashENSQueryContainer.actions);
    final state = ref.watch(splashENSQueryContainer.state);

    return MxcPage(
      layout: LayoutType.scrollable,
      useSplashBackground: true,
      presenter: presenter,
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: MxcAppBar(
        text: '',
        action: MxcAppBarButton.text(
          FlutterI18n.translate(context, 'skip'),
          onTap: () {
            Navigator.of(context).replaceAll(
              route(const HomePage()),
            );
          },
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: MxcButton.primary(
          key: const ValueKey('claimMyUsernameButton'),
          title: FlutterI18n.translate(context, 'claim_my_username'),
          onTap: state.isRegistered ? () => presenter.claim() : null,
        ),
      ),
      children: [
        Text(
          FlutterI18n.translate(context, 'choose_your_username'),
          style: FontTheme.of(context).h4.white(),
        ),
        const SizedBox(height: 16),
        Text(
          FlutterI18n.translate(context, 'ens_register_description'),
          style: FontTheme.of(context).body1.white(),
        ),
        const SizedBox(height: 8),
        Text(
          FlutterI18n.translate(context, 'prowerd_zkevm'),
          style: FontTheme.of(context).caption1.white().copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
        ),
        const SizedBox(height: 32),
        QueryTextfield(
          key: const ValueKey('queryName'),
          controller: state.usernameController,
          onChanged: (vlaue) => presenter.queryNameAvailable(),
          errorText: state.errorText,
        ),
      ],
    );
  }
}
