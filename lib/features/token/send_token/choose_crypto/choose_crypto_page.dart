import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'choose_crypto_presenter.dart';
import 'choose_crypto_state.dart';

class ChooseCryptoPage extends HookConsumerWidget {
  const ChooseCryptoPage({Key? key}) : super(key: key);

  @override
  ProviderBase<ChooseCryptoPresenter> get presenter =>
      addTokenPageContainer.actions;

  @override
  ProviderBase<ChooseCryptoState> get state => addTokenPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: AppNavBar(
        action: IconButton(
          key: const ValueKey('appsButton'),
          icon: const Icon(MXCIcons.dapps),
          iconSize: 24,
          onPressed: () =>
              Navigator.of(context).replaceAll(route(const AppsPage())),
          color: ColorsTheme.of(context).primaryButton,
        ),
      ),
      children: [
        Text(
          FlutterI18n.translate(context, 'send_token'),
          style: FontTheme.of(context).h4(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FlutterI18n.translate(context, 'choose_token'),
              style: FontTheme.of(context).body1.secondary(),
            ),
            MxcTextField.search(
              key: const ValueKey('chooseTokenTextField'),
              width: 150,
              backgroundColor: ColorsTheme.of(context).chipDefaultBg,
              prefix: const Icon(Icons.search_rounded),
              hint: translate('find_your_token'),
              controller: ref.read(presenter).searchController,
              action: TextInputAction.done,
              onChanged: (value) {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        const RecentTransactions()
      ],
    );
  }
}
