import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/apps_page/widgets/dapps_page_view.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../widgets/dapp_indicator.dart';
import '../widgets/dapp_icon.dart';

import 'apps_page_presenter.dart';
import 'apps_page_state.dart';

class AppsPage extends HookConsumerWidget {
  const AppsPage({Key? key}) : super(key: key);

  @override
  ProviderBase<AppsPagePresenter> get presenter =>
      appsPagePageContainer.actions;

  @override
  ProviderBase<AppsPagePageState> get state => appsPagePageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(state).bookmarks;
    final pages = ref.watch(state).pages;

    return MxcPage(
      isEditMode: ref.watch(state).isEditMode,
      onAdd: () => Navigator.of(context).push(
        route.featureDialog(
          const AddDApp(),
        ),
      ),
      onDone: () => ref.read(presenter).changeEditMode(),
      layout: LayoutType.column,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      backgroundColor: ColorsTheme.of(context).secondaryBackground,
      appBar: AppNavBar(
        leading: IconButton(
          key: const ValueKey('menusButton'),
          icon: const Icon(MXCIcons.burger_menu),
          iconSize: 24,
          onPressed: () {},
          color: ColorsTheme.of(context).primaryButton,
        ),
        action: IconButton(
          key: const ValueKey('walletButton'),
          icon: const Icon(MXCIcons.wallet),
          iconSize: 24,
          onPressed: () => Navigator.of(context).replaceAll(
            route(
              const HomePage(),
            ),
          ),
          color: ColorsTheme.of(context).primaryButton,
        ),
      ),
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView(
                onPageChanged: (index) =>
                    ref.read(presenter).onPageChage(index),
                children: [
                  DAppsPageView(
                    bookmarks: bookmarks,
                    onLayoutChange: (rowCount) =>
                        ref.read(presenter).updatePage(0, rowCount),
                    onLongPress: () => ref.read(presenter).changeEditMode(),
                    onRemoveTap: (item) =>
                        ref.read(presenter).removeBookmark(item),
                    isEditMode: ref.watch(state).isEditMode,
                    child: Column(
                      children: [
                        DAppIcon(
                          dapp: DApp(
                            name: 'Bridge',
                            description: '& Faucet',
                            url: 'https://wannsee-bridge.mxc.com',
                            image: 'assets/images/apps/bridge.png',
                          ),
                          isEditMode: ref.watch(state).isEditMode,
                        ),
                        DAppIcon(
                          dapp: DApp(
                            name: 'Stablecoin',
                            description: 'world_un_depeggable',
                            url: 'https://wannsee-xsd.mxc.com',
                            image: 'assets/images/apps/stable_coin.png',
                          ),
                          isEditMode: ref.watch(state).isEditMode,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: DAppIcon(
                                dapp: DApp(
                                  name: 'MNS',
                                  description: 'Own your .MXC domain',
                                  url: 'https://wannsee-mns.mxc.com',
                                  image: 'assets/images/apps/mns.png',
                                ),
                                isEditMode: ref.watch(state).isEditMode,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: DAppIcon(
                                dapp: DApp(
                                  name: 'NFT',
                                  description: 'digitalize_your_assets',
                                  url: 'https://wannsee-nft.mxc.com',
                                  image: 'assets/images/apps/nft.png',
                                ),
                                isEditMode: ref.watch(state).isEditMode,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  for (int index = 1; index < pages.length; index++) ...[
                    DAppsPageView(
                      bookmarks: bookmarks.sublist(pages[index - 1] * 4,
                          index + 1 < pages.length ? pages[index + 1] : null),
                      onLayoutChange: (rowCount) =>
                          ref.read(presenter).updatePage(index, rowCount),
                      onLongPress: () => ref.read(presenter).changeEditMode(),
                      onRemoveTap: (item) =>
                          ref.read(presenter).removeBookmark(item),
                      isEditMode: ref.watch(state).isEditMode,
                    ),
                  ],
                ],
              ),
              if (pages.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: DAppIndicator(
                      selectedIndex: ref.watch(state).pageIndex,
                      total: pages.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
