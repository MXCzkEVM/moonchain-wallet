import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:moonchain_wallet/features/dapps/presentation/dapps_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../dapps_state.dart';
import '../widgets/dapp_indicator.dart';
import 'dapps_layout/card_item.dart';
import 'dapp_loading.dart';
import 'dapp_utils.dart';
import 'dapps_layout/dapp_card.dart';

class DappCardLayout extends HookConsumerWidget {
  const DappCardLayout({
    super.key,
    this.crossAxisCount = CardCrossAxisCount.mobile,
    this.mainAxisCount = CardMainAxisCount.mobile,
  });

  final int crossAxisCount;
  final int mainAxisCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appsPagePageContainer.state);
    final actions = ref.read(appsPagePageContainer.actions);
    final dapps = state.orderedDapps;

    final List<Dapp> bookmarksDapps = [];
    final List<Dapp> nativeDapps = [];
    final List<Dapp> partnerDapps = [];

    final pages = actions.calculateMaxItemsCount(
        dapps.length, mainAxisCount, crossAxisCount);
    final emptyItems = actions.getRequiredItems(
        dapps.length, mainAxisCount, crossAxisCount, pages);
    List<Widget> emptyWidgets =
        List.generate(emptyItems, (index) => Container());

    if (state.loading && DappUtils.loadingOnce) {
      return DAppLoading(
        crossAxisCount: crossAxisCount,
        mainAxisCount: mainAxisCount,
      );
    }

    if (dapps.isEmpty) return Container();

    String translate(String key) => FlutterI18n.translate(context, key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expanded(
        //   flex: 2,
        //   child: LayoutBuilder(
        //     builder: (context, constraint) {
        //       actions.initializeViewPreferences(constraint.maxWidth);
        //       final itemWidth = actions.getItemWidth();
        //       return ReorderableWrapperWidget(
        //         dragWidgetBuilder: DragWidgetBuilderV2(
        //           builder: (index, child, screenshot) {
        //             return Container(
        //               child: child,
        //             );
        //           },
        //         ),
        //         // the drag and drop index is from (index passed to ReorderableItemView)
        //         onReorder: (dragIndex, dropIndex) {
        //           actions.handleOnReorder(dropIndex, dragIndex);
        //         },
        //         onDragUpdate: (dragIndex, position, delta) =>
        //             actions.handleOnDragUpdate(position),
        //         child: GridView(
        //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //             crossAxisCount: crossAxisCount,
        //             mainAxisExtent: constraint.maxWidth / mainAxisCount,
        //           ),
        //           scrollDirection: Axis.horizontal,
        //           physics: const PageScrollPhysics(),
        //           controller: actions.scrollController,
        //           children: [
        //             ...getList(dapps, actions, state, itemWidth, mainAxisCount),
        //             ...emptyWidgets
        //           ],
        //         ),
        //       );
        //     },
        //   ),
        // ),
        DAppProviderHeader(
          providerTitle: '${translate('native')} ${translate('dapps')}',
        ),
        Expanded(
          flex: 2,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2 / 3,
            ),
            itemCount: dapps.length,
            itemBuilder: (context, index) => DAppCard(
              index: index,
              // width: itemWidth,
              dapp: dapps[index],
              mainAxisCount: mainAxisCount,
            ),
          ),
        ),
        DAppProviderHeader(
          providerTitle: '${translate('partner')} ${translate('dapps')}',
        ),
        Expanded(
          flex: 2,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2 / 3,
            ),
            itemCount: dapps.length,
            itemBuilder: (context, index) => DAppCard(
              index: index,
              // width: itemWidth,
              dapp: dapps[index],
              mainAxisCount: mainAxisCount,
            ),
          ),
        ),
        DAppProviderHeader(
          providerTitle: translate('bookmark'),
        ),
        Expanded(
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2 / 3,
            ),
            itemCount: dapps.length,
            itemBuilder: (context, index) => DAppCard(
              index: index,
              // width: itemWidth,
              dapp: dapps[index],
              mainAxisCount: mainAxisCount,
            ),
          ),
        ),
        // const SizedBox(
        //   height: Sizes.spaceXLarge,
        // ),
        // DAppIndicator(
        //   total: pages,
        //   selectedIndex: state.pageIndex,
        // ),
      ],
    );
  }
}

// List<Widget> getList(List<Dapp> dapps, DAppsPagePresenter actions,
//     DAppsState state, double itemWidth, int mainAxisCount) {
//   List<Widget> dappCards = [];

//   for (int i = 0; i < dapps.length; i++) {
//     final item = dapps[i];
//     final dappCard = DAppCard(
//       index: i,
//       // width: itemWidth,
//       dapp: item,
//       mainAxisCount: mainAxisCount,
//     );
//     dappCards.add(dappCard);
//   }

//   return dappCards;
// }

class DAppProviderHeader extends StatelessWidget {
  final String providerTitle;
  const DAppProviderHeader({super.key, required this.providerTitle});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Text(
          providerTitle,
          style: FontTheme.of(context).h7().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: ColorsTheme.of(context).textPrimary),
        ),
        const Spacer(),
        Text(
          FlutterI18n.translate(context, 'see_all'),
          style: FontTheme.of(context).h7().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: ColorsTheme.of(context).textPrimary),
        ),
      ],
    );
  }
}

class DappsGridView extends StatelessWidget {
  final int flex;
  final int crossAxisCount;
  final List<Dapp> dapps;
  final int mainAxisCount;

  const DappsGridView({
    super.key,
    required this.flex,
    required this.crossAxisCount,
    required this.dapps,
    required this.mainAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2 / 3,
        ),
        itemCount: dapps.length,
        itemBuilder: (context, index) => DAppCard(
          index: index,
          dapp: dapps[index],
          mainAxisCount: mainAxisCount,
        ),
      ),
    );
  }
}
