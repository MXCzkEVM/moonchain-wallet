import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:moonchain_wallet/features/dapps/presentation/dapps_presenter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';

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

    final List<Dapp> bookmarksDapps = actions.getBookmarkDapps();
    final List<Dapp> nativeDapps = actions.getNativeDapps();
    final List<Dapp> partnerDapps = actions.getPartnerDapps();

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

    Widget constraintWrapperWidget(Widget child) => ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 780),
          child: child,
        );

    if (state.seeAllDapps != null) {
      return DAppsListView(mainAxisCount: mainAxisCount);
    }

    return constraintWrapperWidget(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...buildDAppProviderSection(
              '${translate('native')} ${translate('dapps')}',
              nativeDapps,
              2,
              2,
              mainAxisCount),
          ...buildDAppProviderSection(
              '${translate('partner')} ${translate('dapps')}',
              partnerDapps,
              2,
              2,
              mainAxisCount),
          ...buildDAppProviderSection(
              translate('bookmark'), bookmarksDapps, 1, 1, mainAxisCount),
        ],
      ),
    );
  }
}
