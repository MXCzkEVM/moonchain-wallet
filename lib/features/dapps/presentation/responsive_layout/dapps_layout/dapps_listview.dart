import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'dapps_layout.dart';

class DAppsListView extends StatelessWidget {
  final List<Dapp> dapps;
  final int mainAxisCount;
  const DAppsListView({
    super.key,
    required this.dapps,
    required this.mainAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          key: const ValueKey('backButton'),
          icon: const Icon(Icons.arrow_back_rounded),
          iconSize: 28,
          onPressed: () => print('object'),
          color: ColorsTheme.of(context).iconPrimary,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dapps.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) => DAppCard(
              index: index,
              dapp: dapps[index],
              mainAxisCount: mainAxisCount,
            ),
          ),
        ),
      ],
    );
  }
}