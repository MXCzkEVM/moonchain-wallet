import 'package:datadashwallet/features/dapps/presentation/dapps_presenter.dart';
import 'package:datadashwallet/features/dapps/presentation/responsive_layout/dapp_card.dart';
import 'package:datadashwallet/features/dapps/presentation/widgets/dapp_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'card_item.dart';
import 'dapp_loading.dart';
import 'dapp_utils.dart';

class DappCardLayout extends HookConsumerWidget {
  const DappCardLayout({
    super.key,
    this.crossAxisCount = CardCrossAxisCount.mobile,
  });

  final int crossAxisCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appsPagePageContainer.state);
    final actions = ref.read(appsPagePageContainer.actions);
    final dapps = state.dappsAndBookmarks;

    if (state.loading && DappUtils.loadingOnce) {
      return DAppLoading(
        crossAxisCount: crossAxisCount,
      );
    }

    if (dapps.isEmpty) return Container();

    final chainId = DappUtils.getChainId(state.network);

    List<List<Dapp>> pages = DappUtils.paging(
      context: context,
      allDapps: dapps,
      chainId: chainId,
      crossAxisCount: crossAxisCount,
    );

    return Stack(
      children: [
        PageView(
          onPageChanged: (index) => actions.onPageChage(index),
          children: pages
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: StaggeredGrid.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      axisDirection: AxisDirection.down,
                      children: e
                          .map((item) => item is Bookmark
                              ? CardSizes.small(
                                  child: DappCard(
                                    dapp: item,
                                    isEditMode: state.isEditMode,
                                    onLongPress: () => actions.changeEditMode(),
                                    onRemoveTap: (item) => actions
                                        .removeBookmark(item as Bookmark),
                                    onTap: state.isEditMode
                                        ? null
                                        : () => actions.openDapp(item.url),
                                  ),
                                )
                              : item.reviewApi!.icons!.islarge!
                                  ? CardSizes.large(
                                      child: DappCard(
                                        dapp: item,
                                        isEditMode: false,
                                        onLongPress: () =>
                                            actions.changeEditMode(),
                                        onTap: state.isEditMode
                                            ? null
                                            : () async {
                                                // await actions
                                                //     .requestPermissions(item);
                                                actions.openDapp(
                                                  item.app!.url!,
                                                );
                                              },
                                      ),
                                    )
                                  : CardSizes.medium(
                                      child: DappCard(
                                        dapp: item,
                                        isEditMode: false,
                                        onLongPress: () =>
                                            actions.changeEditMode(),
                                        onTap: state.isEditMode
                                            ? null
                                            : () async {
                                                // await actions
                                                //     .requestPermissions(item);
                                                actions.openDapp(
                                                  item.app!.url!,
                                                );
                                              },
                                      ),
                                    ))
                          .toList(),
                    ),
                  ))
              .toList(),
        ),
        if (pages.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: DAppIndicator(
                selectedIndex: state.pageIndex,
                total: pages.length,
              ),
            ),
          ),
      ],
    );
  }
}
