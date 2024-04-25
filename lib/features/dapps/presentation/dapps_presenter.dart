import 'dart:async';
import 'dart:io';

import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
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
  final scrollController = ScrollController();

  int currentPage = 1;
  int attemptCount = 0;
  Timer? timer;
  bool onLeftEdge = false;
  bool onRightEdge = false;
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
        notify(() => state.network = value);
        loadPage();
      }
    });

    listen<List<Dapp>>(
      _dappStoreUseCase.dapps,
      (v) {
        state.dapps = v;
        state.dappsAndBookmarks.clear();
        state.dappsAndBookmarks = [...v, ...state.bookmarks];
        updateDappsOrder();
        if (v.isNotEmpty) {
          DappUtils.loadingOnce = false;
          notify(() => state.loading = false);
        }
        notify();
      },
    );

    listen(_dappsOrderUseCase.order, (v) {
      notify(() => state.dappsOrder = v);
      updateReorderedDapps();
    });

    listen<List<Bookmark>>(
      _bookmarksUseCase.bookmarks,
      (v) {
        state.bookmarks = v;
        state.dappsAndBookmarks.clear();
        state.dappsAndBookmarks = [...state.dapps, ...v];
        notify();
      },
    );
  }

  void loadPage() {
    initializeDapps();
  }

  void initializeDapps() async {
    try {
      await _dappStoreUseCase.getAllDapps();
    } catch (e, s) {
      addError(e, s);
    }
  }

  void removeBookmark(Bookmark item) {
    _bookmarksUseCase.removeItem(item);
  }

  void onPageChage(int index) => notify(() => state.pageIndex = index);

  void changeEditMode() => notify(() => state.isEditMode = !state.isEditMode);
  void resetEditMode() => notify(() => state.isEditMode = false);

  void setGesturesInstruction() {
    _gesturesInstructionUseCase.setEducated(true);
  }

  Future<void> requestPermissions(Dapp dapp) async {
    // Permission request will be only on Android
    if (Platform.isAndroid) {
      final permissions = dapp.app!.permissions!.toMap();
      final keys = permissions.keys.toList();
      final values = permissions.values.toList();
      List<Permission> needPermissions = [];

      for (int i = 0; i < permissions.length; i++) {
        final key = keys[i];
        final value = values[i];

        if (value == 'required') {
          final permission = PermissionUtils.permissions[key];
          if (permission != null) {
            needPermissions.add(permission);
          }
        }
      }

      if (keys.contains('location')) {
        await checkLocationService();
      }
      if (needPermissions.isNotEmpty) {
        await needPermissions.request();
        await PermissionUtils.permissionsStatus();
      }
    }
  }

  void refreshApp() {
    _chainConfigurationUseCase.refresh();
    _accountUseCase.refresh();
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

  Future<bool> checkLocationService() async {
    final geo.GeolocatorPlatform geoLocatorPlatform =
        geo.GeolocatorPlatform.instance;

    bool _serviceEnabled;

    try {
      _serviceEnabled = await geoLocatorPlatform.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        await geoLocatorPlatform.getCurrentPosition();
        _serviceEnabled = await geoLocatorPlatform.isLocationServiceEnabled();
      }
      return _serviceEnabled;
    } catch (e) {
      return false;
    }
  }

  double edgeScrollingSensitivity = 40;

  void initializeViewPreferences(double maxWidth) {
    viewPortWidth = maxWidth;
    scrollingArea = maxWidth - edgeScrollingSensitivity;
  }

  double getItemWidth() {
    return viewPortWidth! / 3;
  }

  // index -> dapp repo usecase
  // Remove reordering pagination

  void handleOnReorder() {
    // var item = data.removeAt(dragIndex);
    // data.insert(dropIndex, item);
  }

  void handleOnDragUpdate(Offset position) {
    print(position.dx < 0);
    print(position.dx > scrollingArea!);
    if (position.dx <= edgeScrollingSensitivity) {
      startTimer();
      onLeftEdge = true;
    } else if (position.dx > scrollingArea!) {
      startTimer();
      onRightEdge = true;
    } else {
      cancelTimer();
    }

    print('position: ' + position.toString());
  }

  void changePageToLeft() {
    scrollController.animateTo(
        scrollController.position.pixels - MediaQuery.of(context!).size.width,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut);
    currentPage += 1;
  }

  void changePageToRight() {
    scrollController.animateTo(
        scrollController.position.pixels + MediaQuery.of(context!).size.width,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut);
    currentPage -= 1;
  }

  void cancelTimer() {
    timer?.cancel();
    timer = null;
    resetLeftAndRight();
  }

  void resetLeftAndRight() {
    onLeftEdge = false;
    onRightEdge = false;
  }

  void startTimer() {
    timer ??= Timer(const Duration(seconds: 1), () {
      if (onLeftEdge) {
        changePageToLeft();
      } else if (onRightEdge) {
        changePageToRight();
      }
      resetLeftAndRight();
    });
  }

  void updateReorderedDapps() {
    final chainDapps = getChainDapps();
    final newOrderDapps = DappUtils.reorderDApps(chainDapps, state.dappsOrder);
    notify(
      () => state.orderedDapps = newOrderDapps,
    );
  }

  List<Dapp> getChainDapps() {
    List<Dapp> chainDapps = DappUtils.getDappsByChainId(
      allDapps: state.dappsAndBookmarks,
      chainId: state.network!.chainId,
    );
    return chainDapps;
  }

  void updateDappsOrder() {
    final chainDapps = getChainDapps();
    _dappsOrderUseCase.updateOrder(dapps: chainDapps);
  }

  @override
  Future<void> dispose() async {
    timer!.cancel();
    super.dispose();
  }
}
