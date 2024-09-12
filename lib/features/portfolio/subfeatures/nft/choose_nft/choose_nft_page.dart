import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/nft_list/nft_list.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/send_nft/send_nft_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'choose_nft_presenter.dart';
import 'choose_nft_state.dart';

class ChooseNftPage extends HookConsumerWidget {
  const ChooseNftPage({Key? key}) : super(key: key);

  @override
  ProviderBase<ChooseNftPresenter> get presenter =>
      chooseNftPageContainer.actions;

  @override
  ProviderBase<ChooseNftState> get state => chooseNftPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: AppNavBar(
        action: IconButton(
          key: const ValueKey('appsButton'),
          icon: const Icon(MxcIcons.apps),
          iconSize: 32,
          onPressed: () =>
              Navigator.of(context).replaceAll(route(const DAppsPage())),
          color: ColorsTheme.of(context).iconPrimary,
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
              onChanged: (value) => ref.read(presenter).fliterNfts(value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        NFTList(
          onSelected: (nft) => Navigator.of(context).push(
            route.featureDialog(SendNftPage(nft: nft)),
          ),
          nfts: ref.watch(state).filterNfts,
        ),
      ],
    );
  }
}
