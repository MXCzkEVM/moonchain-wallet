import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'dapps_layout.dart';

List<Widget> buildDAppProviderSection(
  String providerTitle,
  List<Dapp> dapps,
  int flex,
  int crossAxisCount,
  int mainAxisCount,
) {
  if (dapps.isEmpty) {
    return [
      DappsGridView(
        flex: flex,
        crossAxisCount: crossAxisCount,
        dapps: const [],
        mainAxisCount: mainAxisCount,
      ),
    ];
  } else {
    return [
      DAppProviderHeader(
        providerTitle: providerTitle,
        dapps: dapps,
      ),
      DappsGridView(
        flex: flex,
        crossAxisCount: crossAxisCount,
        dapps: dapps,
        mainAxisCount: mainAxisCount,
      ),
    ];
  }
}