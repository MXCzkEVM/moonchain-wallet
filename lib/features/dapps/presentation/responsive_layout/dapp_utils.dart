import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'card_item.dart';

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
    transformBookMarkToDapp(allDapps);

    final dapps = allDapps.where((e) {
      if (e is Bookmark) {
        return true;
      } else {
        return (e.store!.chainid == chainId) &&
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
      final aUrl  = a is Bookmark ? a.url : a.app!.url!;
      final bUrl  = b is Bookmark ? b.url : b.app!.url!;
      int indexA = urlIndices[aUrl] ?? dapps.length;
      int indexB = urlIndices[bUrl] ?? dapps.length;
      return dappsOrder.indexOf(aUrl) - dappsOrder.indexOf(bUrl);
    });

    return dapps;
  }

  static List<List<Dapp>> paging({
    required BuildContext context,
    required List<Dapp> allDapps,
    required int chainId,
    int crossAxisCount = CardCrossAxisCount.mobile,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidthRate = crossAxisCount;
    final cardHeightRate =
        (screenSize.height - 165) * cardWidthRate / (screenSize.width - 20);

    // bookmark that are dapp but added manually should be transformed to dapp
    transformBookMarkToDapp(allDapps);
    allDapps;

    final dapps = allDapps.where((e) {
      if (e is Bookmark) {
        return true;
      } else {
        return (e.store!.chainid == chainId) &&
            isSupported(e.app!.supportedPlatforms!);
      }
    }).toList();

    final totalCardsCount = dapps.fold<int>(
        0,
        (sum, e) => (e is Bookmark)
            ? 1
            : ((e.reviewApi!.icons!.islarge! ? 4 : 2) * 2) + sum);
    final pagingCount =
        (totalCardsCount / (cardWidthRate * cardHeightRate)).ceil() + 3;

    List<List<Dapp>> pages = List.generate(pagingCount, (index) => []);
    int itemIndex = 0;

    for (int pageIndex = 0; pageIndex < pagingCount; pageIndex++) {
      var pageHeight = cardHeightRate;
      var pageWidth = crossAxisCount;

      for (itemIndex; itemIndex < dapps.length; itemIndex++) {
        final itemWidth = dapps[itemIndex] is Bookmark
            ? 1
            : dapps[itemIndex].reviewApi!.icons!.islarge!
                ? 4
                : 2;
        const itemHeight = 2;
        if (pageHeight - itemHeight >= 0) {
          if (pageWidth - itemWidth >= 0) {
            pageWidth -= itemWidth;
            pages[pageIndex].add(dapps[itemIndex]);
            if (pageWidth == 0) {
              pageHeight -= itemHeight;
              pageWidth = crossAxisCount;
            }
          } else {
            pageWidth = crossAxisCount;
            pageHeight -= itemHeight;
            if (pageHeight - itemHeight >= 0) {
              pages[pageIndex].add(dapps[itemIndex]);
              pageHeight -= itemHeight;
              pageWidth -= itemWidth;
              if (pageWidth == 0) {
                pageWidth = crossAxisCount;
              }
            } else {
              break;
            }
          }
        } else {
          break;
        }
      }
    }

    pages = pages.where((e) => e.isNotEmpty).toList();

    return pages;
  }

  static void transformBookMarkToDapp(List<Dapp> allDapps) {
    for (int i = 0; i < allDapps.length; i++) {
      var b = allDapps[i];

      if (b is Bookmark) {
        b = b as Bookmark;
        for (int j = 0; j < allDapps.length; j++) {
          final e = allDapps[j];
          if (j == i) {
            continue;
          }
          if (e.app != null && e.app!.url != null) {
            if (e.app!.url!.contains(b.url) || b.url.contains(e.app!.url!)) {
              allDapps[i] = e.fromBookmark(b);
            }
          }
        }
      }
    }
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
