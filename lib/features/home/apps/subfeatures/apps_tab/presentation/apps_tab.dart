import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/apps_tab/widgets/dapps_page_view.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../widgets/dapp_indicator.dart';
import '../widgets/dapp_icon.dart';

import 'apps_tab_presenter.dart';
import 'apps_tab_state.dart';

class AppsTab extends HookConsumerWidget {
  const AppsTab({Key? key}) : super(key: key);

  @override
  ProviderBase<AppsTabPresenter> get presenter => appsTabPageContainer.actions;

  @override
  ProviderBase<AppsTabPageState> get state => appsTabPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(state).bookmarks;
    final pages = ref.watch(state).pages;

    return Expanded(
      child: Stack(
        children: [
          PageView(
            onPageChanged: (index) => ref.read(presenter).onPageChage(index),
            children: [
              DAppsPageView(
                bookmarks: bookmarks,
                onLayoutChange: (rowCount) =>
                    ref.read(presenter).updatePage(0, rowCount),
                onLongPress: () =>
                    ref.read(homeContainer.actions).changeEditMode(),
                onRemoveTap: (item) => ref.read(presenter).removeBookmark(item),
                isEditMode: ref.watch(homeContainer.state).isEditMode,
                child: Column(
                  children: [
                    DAppIcon(
                      dapp: DApp(
                        name: 'Bridge',
                        description: '& Faucet',
                        url: 'https://wannsee-bridge.mxc.com',
                        image: 'assets/images/apps/bridge.png',
                      ),
                      isEditMode: ref.watch(homeContainer.state).isEditMode,
                    ),
                    DAppIcon(
                      dapp: DApp(
                        name: 'Stablecoin',
                        description: 'world_un_depeggable',
                        url: 'https://wannsee-xsd.mxc.com',
                        image: 'assets/images/apps/stable_coin.png',
                      ),
                      isEditMode: ref.watch(homeContainer.state).isEditMode,
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
                            isEditMode:
                                ref.watch(homeContainer.state).isEditMode,
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
                            isEditMode:
                                ref.watch(homeContainer.state).isEditMode,
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
                  onLongPress: () =>
                      ref.read(homeContainer.actions).changeEditMode(),
                  onRemoveTap: (item) =>
                      ref.read(presenter).removeBookmark(item),
                  isEditMode: ref.watch(homeContainer.state).isEditMode,
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
    );
  }
}
