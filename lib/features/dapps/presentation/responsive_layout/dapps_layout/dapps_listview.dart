import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../dapps_presenter.dart';
import 'dapps_layout.dart';

class DAppsListView extends HookConsumerWidget {
  final int mainAxisCount;
  const DAppsListView({
    super.key,
    required this.mainAxisCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appsPagePageContainer.state);
    final actions = ref.read(appsPagePageContainer.actions);

    final dapps = state.seeAllDapps;

    if (dapps == null) {
      return Container();
    }

    final itemMaxWidth = MediaQuery.of(context).size.width / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          key: const ValueKey('backButton'),
          icon: const Icon(Icons.arrow_back_rounded),
          iconSize: 28,
          onPressed: () => actions.deselectSeeAllDApps(),
          color: ColorsTheme.of(context).iconPrimary,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dapps.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: itemMaxWidth > 250 ? 250 : itemMaxWidth,
                ),
                child: DAppCard(
                  index: index,
                  dapp: dapps[index],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
