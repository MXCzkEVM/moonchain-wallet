import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'dapps_layout/card_item.dart';

class DappUtils {
  static bool loadingOnce = true;

  static int getChainId(Network? network) {
    if (network!.chainId == Config.mxcTestnetChainId) {
      return network.chainId;
    }

    return 18686;
  }

  static List<Dapp> getDappsByChainId({
    required List<Dapp> allDapps,
    required int chainId,
  }) {
    final dapps = allDapps.where((e) {
      if (e is Bookmark) {
        return true;
      } else {
        return (!MXCChains.isMXCChains(chainId)
                ? MXCChains.isMXCMainnet(e.store!.chainid!)
                : e.store!.chainid == chainId) &&
            isSupported(e.app!.supportedPlatforms!);
      }
    }).toList();

    return dapps;
  }

  /// This function will return dapps order according to dappsOrder variable
  static List<Dapp> reorderDApps(List<Dapp> dapps, List<String> dappsOrder) {
    // Create a map to store the indices of each DApp URL
    Map<String, int> urlIndices = {};
    for (int i = 0; i < dapps.length; i++) {
      final dapp = dapps[i];
      urlIndices[dapp is Bookmark ? dapp.url : dapp.app!.url!] = i;
    }

    // Sort the DApps list based on the order specified in dappsOrder
    dapps.sort((a, b) {
      final aUrl = a is Bookmark ? a.url : a.app!.url!;
      final bUrl = b is Bookmark ? b.url : b.app!.url!;
      int indexA = urlIndices[aUrl] ?? dapps.length;
      int indexB = urlIndices[bUrl] ?? dapps.length;
      return dappsOrder.indexOf(aUrl) - dappsOrder.indexOf(bUrl);
    });

    return dapps;
  }

  static bool isSupported(List<dynamic> sPlatforms) {
    if (Platform.isAndroid) {
      final supported =
          sPlatforms.any((e) => (e as String).toLowerCase() == 'android');
      return supported;
    } else {
      final supported =
          sPlatforms.any((e) => (e as String).toLowerCase() == 'ios');
      return supported;
    }
  }
}
