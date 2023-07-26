import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/dapps/entities/bookmark.dart';
import 'package:datadashwallet/features/settings/settings.dart';
import 'package:datadashwallet/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'widgets/bookmark.dart';
import 'widgets/dapp_indicator.dart';
import 'dapps_presenter.dart';
import 'dapps_state.dart';
import 'widgets/edit_mode_status_bar.dart';

class DAppsPage extends HookConsumerWidget {
  const DAppsPage({Key? key}) : super(key: key);

  @override
  ProviderBase<DAppsPagePresenter> get presenter =>
      appsPagePageContainer.actions;

  @override
  ProviderBase<DAppsState> get state => appsPagePageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(state).bookmarks;
    final bodyHeight = MediaQuery.of(context).size.height - 160;
    final gridRows = (bodyHeight / 80).floor();

    final gridItemsTotal =
        bookmarks.fold<int>(0, (sum, item) => item.occupyGrid + sum);
    final paginationsTotal = (gridItemsTotal / (gridRows * 4)).ceil();

    List<List<Bookmark>> pages = List.generate(paginationsTotal, (index) => []);
    int itemIndex = 0;

    for (int pageIndex = 0; pageIndex < paginationsTotal; pageIndex++) {
      int sumItems = 0;

      for (itemIndex; itemIndex < bookmarks.length; itemIndex++) {
        final currentGridRows = bookmarks[itemIndex].occupyGrid;
        if (currentGridRows == 4) {
          if (sumItems + 8 > gridRows * 4) {
            break;
          }
        }
        sumItems += currentGridRows;

        if (sumItems <= gridRows * 4) {
          pages[pageIndex].add(bookmarks[itemIndex]);
        } else {
          break;
        }
      }
    }

    return Stack(
      children: [
        MxcPage(
          layout: LayoutType.scrollable,
          useContentPadding: false,
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          backgroundColor: ColorsTheme.of(context).screenBackground,
          appBar: Column(
            children: [
              if (ref.watch(state).isEditMode) ...[
                EditAppsModeStatusBar(
                  onAdd: () => Navigator.of(context).push(
                    route.featureDialog(const addBookmark()),
                  ),
                  onDone: () => ref.read(presenter).changeEditMode(),
                ),
              ],
              AppNavBar(
                leading: IconButton(
                  key: const ValueKey('settingsButton'),
                  icon: const Icon(MXCIcons.settings),
                  iconSize: 32,
                  onPressed: () {
                    Navigator.of(context).push(
                      route(
                        const SettingsPage(),
                      ),
                    );
                  },
                  color: ColorsTheme.of(context).iconPrimary,
                ),
                action: IconButton(
                  key: const ValueKey('walletButton'),
                  icon: const Icon(MXCIcons.wallet),
                  iconSize: 32,
                  onPressed: () => Navigator.of(context).replaceAll(
                    route(const WalletPage()),
                  ),
                  color: ColorsTheme.of(context).iconPrimary,
                ),
              ),
            ],
          ),
          children: [
            SizedBox(
              height: bodyHeight,
              child: PageView(
                onPageChanged: (index) =>
                    ref.read(presenter).onPageChage(index),
                children: pages
                    .map((page) => Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: page
                              .map((item) => BookmarkWidget(
                                    bookmark: item,
                                    onTap: ref.watch(state).isEditMode
                                        ? null
                                        : () => openAppPage(context, item),
                                    onLongPress: () =>
                                        ref.read(presenter).changeEditMode(),
                                    onRemoveTap: (item) => ref
                                        .read(presenter)
                                        .removeBookmark(item),
                                    isEditMode: ref.watch(state).isEditMode,
                                  ))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        if (pages.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: DAppIndicator(
                selectedIndex: ref.watch(state).pageIndex,
                total: pages.length,
              ),
            ),
          ),
      ],
    );
  }
}
