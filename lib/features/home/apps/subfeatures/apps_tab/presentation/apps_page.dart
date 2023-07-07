import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/apps_tab/widgets/dapps_page_view.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
      appBar: AppBar(
        elevation: 0.0,
        leading: MxcCircleButton.icon(
          key: const Key("burgerMenuButton"),
          icon: Icons.menu_rounded,
          shadowRadius: 0,
          onTap: () {},
          iconSize: 30,
          color: ColorsTheme.of(context).primaryText,
          iconFillColor: Colors.transparent,
        ),
        shadowColor: Colors.transparent,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: MxcCircleButton.icon(
              key: const Key("appsButton"),
              icon: MXCIcons.wallet,
              shadowRadius: 30,
              onTap: () {
                Navigator.of(context).replaceAll(
                  route(
                    const HomePage(),
                  ),
                );
              },
              iconSize: 30,
              color: ColorsTheme.of(context).primaryText,
              iconFillColor: ColorsTheme.of(context).secondaryBackground,
            ),
          ),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: ColorsTheme.of(context).white.withOpacity(0.16),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Row(
                    children: [
                      MXCDropDown<String>(
                        itemList: const ["MXC zkEVM", "Testnet"],
                        onChanged: (String? newValue) {},
                        selectedItem: "MXC zkEVM",
                        icon: const Padding(
                          padding: EdgeInsetsDirectional.only(start: 10),
                        ),
                      ),
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                            color: ColorsTheme.of(context).systemStatusActive,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(FlutterI18n.translate(context, 'online'),
                          style: FontTheme.of(context)
                              .h7()
                              .copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                // MXCDropDown<String>(
                //   itemList: [
                //     "",
                //   ],
                //   onChanged: (String? newValue) {},
                //   selectedItem: "",
                //   textStyle: FontTheme.of(context)
                //       .h7()
                //       .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
                //   icon: Padding(
                //     padding: const EdgeInsetsDirectional.only(start: 0),
                //     child: Icon(
                //       Icons.arrow_drop_down_rounded,
                //       size: 32,
                //       color: ColorsTheme.of(context).purpleMain,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
        backgroundColor: ColorsTheme.of(context).secondaryBackground,
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
