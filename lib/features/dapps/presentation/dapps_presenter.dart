import 'dart:async';

import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:moonchain_wallet/features/dapps/helpers/book_marks_helper.dart';
import 'package:moonchain_wallet/features/dapps/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'dapps_state.dart';
import 'responsive_layout/dapp_utils.dart';
import 'widgets/gestures_instruction.dart';

final appsPagePageContainer =
    PresenterContainer<DAppsPagePresenter, DAppsState>(
        () => DAppsPagePresenter());

class DAppsPagePresenter extends CompletePresenter<DAppsState> {
  DAppsPagePresenter() : super(DAppsState());

  late final _bookmarksUseCase = ref.read(bookmarksUseCaseProvider);
  late final _dappStoreUseCase = ref.read(dappStoreUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _gesturesInstructionUseCase =
      ref.read(gesturesInstructionUseCaseProvider);
  late final _accountUseCase = ref.read(accountUseCaseProvider);
  late final _dappsOrderUseCase = ref.read(dappsOrderUseCaseProvider);

  PaginationHelper get paginationHelper => PaginationHelper(
        notify: notify,
        state: state,
        translate: translate,
        context: context,
        scrollController: scrollController,
        viewPortWidth: viewPortWidth,
      );

  GestureNavigationHelper get gestureNavigationHelper =>
      GestureNavigationHelper(
        state: state,
        translate: translate,
        context: context,
        scrollController: scrollController,
        scrollingArea: scrollingArea,
      );

  ReorderHelper get reorderHelper => ReorderHelper(
        dappsOrderUseCase: _dappsOrderUseCase,
        state: state,
        translate: translate,
        notify: notify,
      );

  PermissionsHelper get permissionsHelper => PermissionsHelper(
        translate: translate,
        notify: notify,
        context: context,
      );

  BookMarksHelper get bookmarksHelper => BookMarksHelper(
        bookmarkUseCase: _bookmarksUseCase,
        navigator: navigator,
        translate: translate,
        context: context,
      );

  final scrollController = ScrollController();

  int attemptCount = 0;
  double? viewPortWidth;
  double? scrollingArea;

  @override
  void initState() {
    super.initState();

    // Initializing providers
    ref.read(mxcWebsocketUseCaseProvider);
    ref.read(ipfsUseCaseProvider);
    ref.read(tweetsUseCaseProvider);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    listen(_gesturesInstructionUseCase.educated, (value) {
      notify(() => state.gesturesInstructionEducated = value);
    });

    listen(_chainConfigurationUseCase.networks, (value) {
      _chainConfigurationUseCase.getCurrentNetwork();
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        if (state.network != null && state.network!.chainId != value.chainId) {
          DappUtils.loadingOnce = true;
          notify(() => state.loading = true);
          reorderHelper.resetDappsMerge();
        }
        notify(() => state.network = value);
        loadPage();
      }
    });

    listen(_dappsOrderUseCase.order, (v) {
      notify(() => state.dappsOrder = v);
      reorderHelper.updateReorderedDappsWrapper();
    });

    listen<List<Dapp>>(
      _dappStoreUseCase.dapps,
      (v) {
        state.dapps = v;
        state.dappsAndBookmarks.clear();
        state.dappsAndBookmarks = [...v, ...state.bookmarks];
        if (v.isNotEmpty) {
          state.dappsMerged = true;
        }
        reorderHelper.updateDappsOrderWrapper();
        if (v.isNotEmpty) {
          DappUtils.loadingOnce = false;
          notify(() => state.loading = false);
        }
        notify();
      },
    );

    listen<List<Bookmark>>(
      _bookmarksUseCase.bookmarks,
      (v) {
        state.bookmarks = v;
        state.dappsAndBookmarks.clear();
        state.dappsAndBookmarks = [...state.dapps, ...v];
        state.bookMarksMerged = true;
        reorderHelper.updateDappsOrderWrapper();
        notify();
      },
    );

    initScrollListener();
  }

  initScrollListener() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () => scrollController.addListener(() {
        // inspect(paginationHelper);
        paginationHelper.scrollListener();
      }),
    );
  }

  void loadPage() {
    initializeDapps();
  }

  void initializeDapps() async {
    try {
      await _dappStoreUseCase.loadDapps();
    } catch (e, s) {
      addError(e, s);
    }
  }

  void removeBookmarkDialog(Bookmark item, void Function() animation) async =>
      bookmarksHelper.removeBookmarkDialog(item, animation);

  void removeBookmark(Bookmark item) async =>
      bookmarksHelper.removeBookmark(item);

  void addBookmark() async => bookmarksHelper.addBookmark();

  void updateBookmarkFavIcon(Bookmark item) async =>
      bookmarksHelper.updateBookmarkFavIcon(item);

  void onPageChage(int index) => notify(() => state.pageIndex = index);

  void changeEditMode() => notify(() => state.isEditMode = !state.isEditMode);
  void resetEditMode() => notify(() => state.isEditMode = false);

  void setGesturesInstruction() {
    _gesturesInstructionUseCase.setEducated(true);
  }

  void refreshApp() {
    _chainConfigurationUseCase.refresh();
    _accountUseCase.refresh();
  }

  Future<void> requestPermissions(Dapp dapp) async {
    return await permissionsHelper.requestPermissions(dapp);
  }

  void openDapp(String url) async {
    if (state.gesturesInstructionEducated) {
      openAppPage(context!, url, refreshApp);
    } else {
      final res = await showGesturesInstructionDialog(context!);

      if (res != null && res) {
        _gesturesInstructionUseCase.setEducated(true);
        openAppPage(context!, url, refreshApp);
      }
    }
  }

  int getRequiredItems(
    int itemsCount,
    int mainAxisCount,
    int crossAxisCount,
    int maxPageCount,
  ) {
    return paginationHelper.getRequiredItems(
        itemsCount, mainAxisCount, crossAxisCount, maxPageCount);
  }

  int calculateMaxItemsCount(
      int itemsCount, int mainAxisCount, int crossAxisCount) {
    return paginationHelper.calculateMaxItemsCount(
        itemsCount, mainAxisCount, crossAxisCount);
  }

  void initializeViewPreferences(double maxWidth) {
    viewPortWidth = maxWidth;
    scrollingArea = UIMetricsUtils.calculateScrollingArea(maxWidth);
  }

  double getItemWidth() {
    return UIMetricsUtils.getGridViewItemWidth(viewPortWidth!);
  }

  void handleOnDragUpdate(Offset position) {
    gestureNavigationHelper.handleOnDragUpdate(position);
  }

  void handleOnReorder(int newIndex, int oldIndex) {
    reorderHelper.handleOnReorder(newIndex, oldIndex);
  }

  @override
  Future<void> dispose() async {
    state.timer?.cancel();
    super.dispose();
  }
}
