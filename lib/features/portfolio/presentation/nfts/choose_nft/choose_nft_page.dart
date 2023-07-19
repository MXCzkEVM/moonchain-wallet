import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'choose_nft_presenter.dart';
import 'choose_nft_state.dart';

class ChooseNFTPage extends HookConsumerWidget {
  const ChooseNFTPage({Key? key}) : super(key: key);

  @override
  ProviderBase<ChooseNFTPresenter> get presenter =>
      chooseNFTPageContainer.actions;

  @override
  ProviderBase<ChooseNFTState> get state => chooseNFTPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      onRefresh: () => ref.read(presenter).loadPage(),
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: AppNavBar(
        action: IconButton(
          key: const ValueKey('appsButton'),
          icon: const Icon(MXCIcons.apps),
          iconSize: 32,
          onPressed: () =>
              Navigator.of(context).replaceAll(route(const DAppsPage())),
          color: ColorsTheme.of(context).primaryButton,
        ),
      ),
      children: [
        Text(
          translate('send_x').replaceFirst('{0}', 'NFT'),
          style: FontTheme.of(context).h4(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              translate('choose_x').replaceFirst('{0}', 'NFT'),
              style: FontTheme.of(context).body1.secondary(),
            ),
            MxcTextField.search(
              key: const ValueKey('chooseNfTTextField'),
              width: 150,
              backgroundColor: ColorsTheme.of(context).chipDefaultBg,
              prefix: const Icon(Icons.search_rounded),
              hint: translate('find_your_x').replaceFirst('{0}', 'NFT'),
              controller: ref.read(presenter).searchController,
              action: TextInputAction.done,
              onChanged: (value) => ref.read(presenter).fliterNFTs(value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (ref.watch(state).filterNFTs != null)
          GreyContainer(
              child: Column(
            children: [],
          )),
      ],
    );
  }
}
