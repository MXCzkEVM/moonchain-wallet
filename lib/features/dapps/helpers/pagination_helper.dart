import 'dart:async';

import 'package:flutter/material.dart';

import '../presentation/dapps_state.dart';

class PaginationHelper {
  PaginationHelper(
      {required this.state,
      required this.context,
      required this.scrollController,
      required this.translate,
      required this.notify,
      required this.viewPortWidth});
  DAppsState state;
  BuildContext? context;
  String? Function(String) translate;
  void Function([void Function()? fun]) notify;
  ScrollController scrollController;
  double? viewPortWidth;

  void scrollListener() {
    // print('viewPortWidth: ' + viewPortWidth.toString());
    final page = viewPortWidth == null
        ? 0
        : (scrollController.offset / viewPortWidth!).round();
    if (page != state.pageIndex) {
      notify(() => state.pageIndex = page);
    }
    // print('maxScrollExtent: ' +
    //     scrollController.position.maxScrollExtent.toString());
    // print('page: ' + page.toString());
    // print('scrollController.offset: ' + scrollController.offset.toString());
  }

  void calculateMaxItemsCount(
      int itemsCount, int mainAxisCount, int crossAxisCount) {
    notify(() => state.maxPageCount =
        (itemsCount / (mainAxisCount * crossAxisCount)).ceil());

    print('object :' + state.maxPageCount.toString());
  }

  int getRequiredItems(int itemsCount, int mainAxisCount, int crossAxisCount) {
    final requiredItemsCount =
        (state.maxPageCount * (mainAxisCount * crossAxisCount)) - itemsCount;
    print('requiredItemsCount :' + requiredItemsCount.toString());
    return requiredItemsCount;
  }
}
