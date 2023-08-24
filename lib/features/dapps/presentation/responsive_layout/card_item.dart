import 'package:datadashwallet/features/dapps/entities/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mxc_logic/mxc_logic.dart';

class CardCrossAxisCount {
  static const int mobile = 4;
  static const int tablet = 8;
}

class CardSizes {
  static Widget large({required Widget child}) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 4,
      mainAxisCellCount: 2,
      child: child,
    );
  }

  static Widget medium({required Widget child}) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 2,
      child: child,
    );
  }

  static Widget small({required Widget child}) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: child,
    );
  }
}

List<List<Dapp>> paging({
  required BuildContext context,
  required List<Dapp> dapps,
  int crossAxisCount = CardCrossAxisCount.mobile,
}) {
  final screenSize = MediaQuery.of(context).size;
  final cardWidthRate = crossAxisCount;
  final cardHeightRate =
      (screenSize.height - 165) * cardWidthRate / (screenSize.width - 20);

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
