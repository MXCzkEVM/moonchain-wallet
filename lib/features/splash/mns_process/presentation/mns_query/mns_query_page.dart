import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'mns_query_presenter.dart';
import 'mns_query_state.dart';

class SplashMNSQueryPage extends HookConsumerWidget {
  const SplashMNSQueryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(splashMNSQueryContainer.actions);
    final state = ref.watch(splashMNSQueryContainer.state);

    final formKey = useMemoized(() => GlobalKey<FormState>());

    return MxcPage(
      layout: LayoutType.scrollable,
      useSplashBackground: true,
      presenter: presenter,
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: MxcAppBar(
        text: '',
        action: MxcAppBarButton.text(
          FlutterI18n.translate(context, 'skip'),
          onTap: () => Navigator.of(context).replaceAll(
            route(const DAppsPage()),
          ),
        ),
      ),
      footer: ValueListenableBuilder<TextEditingValue>(
          valueListenable: presenter.usernameController,
          builder: (ctx, usernameValue, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MxcButton.primaryWhite(
                key: const ValueKey('claimMyUsernameButton'),
                title: FlutterI18n.translate(
                    context, state.checking ? 'checking_balance' : 'next'),
                onTap: usernameValue.text.isNotEmpty && !state.checking
                    ? () {
                        FocusManager.instance.primaryFocus?.unfocus();

                        if (!formKey.currentState!.validate()) return;

                        presenter.checkBalance();
                      }
                    : null,
              ),
            );
          }),
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
          FlutterI18n.translate(context, 'powered_by_moonchain_supernodes'),
          style: FontTheme.of(context).caption1.white().copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
        ),
        const SizedBox(height: 32),
        Form(
          key: formKey,
          child: MxcTextField(
            key: const ValueKey('usernameTextField'),
            label: FlutterI18n.translate(context, 'username'),
            controller: presenter.usernameController,
            action: TextInputAction.done,
            validator: (v) => Validation.checkName(context, v),
            followText: '.mxc',
            errorText: state.errorText,
          ),
        ),
      ],
    );
  }
}
