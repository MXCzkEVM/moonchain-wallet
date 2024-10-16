import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'dapps_layout.dart';

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
    // This is the case where dapps Then build empty space
    final isDappsEmpty = dapps.isEmpty;

    return Expanded(
      flex: flex,
      child: isDappsEmpty
          ? Container()
          : GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 4 / 7,
              ),
              itemCount: dapps.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) => DAppCard(
                index: index,
                dapp: dapps[index],
                mainAxisCount: mainAxisCount,
              ),
            ),
    );
  }
}