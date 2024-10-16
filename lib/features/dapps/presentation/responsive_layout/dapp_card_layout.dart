import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:moonchain_wallet/features/dapps/presentation/dapps_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../dapps_state.dart';
import '../widgets/dapp_indicator.dart';
import 'dapp_loading.dart';
import 'dapp_utils.dart';
import 'dapps_layout/dapps_layout.dart';

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

    final List<Dapp> bookmarksDapps = dapps.whereType<Bookmark>().toList();
    final List<Dapp> nativeDapps =
        dapps.where((e) => e.app?.providerType == ProviderType.native).toList();
    final List<Dapp> partnerDapps = dapps
        .where((e) => e.app?.providerType == ProviderType.thirdParty)
        .toList();

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

        ...buildDAppProviderSection('${translate('native')} ${translate('dapps')}', dapps, 2, 2, mainAxisCount),

        ...buildDAppProviderSection('${translate('partner')} ${translate('dapps')}', dapps, 2, 2, mainAxisCount),

        ...buildDAppProviderSection(
            translate('bookmark'), dapps, 1, 1,mainAxisCount),

        Container(
          height: 50,
        )
      ],
    );
  }
}