import 'dart:io';

import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
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

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        notify(() => state.network = value);
      }
    });

    listen<List<Dapp>>(
      _dappStoreUseCase.dapps,
      (v) {
        state.dapps = v;
        state.dappsAndBookmarks.clear();
        state.dappsAndBookmarks = [...v, ...state.bookmarks];
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
        notify();
      },
    );

    listen(_gesturesInstructionUseCase.educated, (value) {
      notify(() => state.gesturesInstructionEducated = value);
    });

    listen(_chainConfigurationUseCase.networks, (value) {
      _chainConfigurationUseCase.getCurrentNetwork();
    });

    listen(_chainConfigurationUseCase.selectedNetwork, (value) {
      if (value != null) {
        loadPage();
      }
    });
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

      if (needPermissions.isNotEmpty) {
        for (Permission permission in needPermissions) {
          await checkPermissionStatusAndRequest(permission);
        }
        await PermissionUtils.permissionsStatus();
      }

      if (keys.contains('location')) {
        await checkLocationService();
      }
    }
  }

  Future<void> checkPermissionStatusAndRequest(
    Permission permission,
  ) async {
    final l =await permission.status;
    if (!(await PermissionUtils.isPermissionGranted(permission)) && !(await PermissionUtils.isPermissionPermanentlyDenied(permission) )) {
      final askForPermission =
          await PermissionUtils.showUseCaseBottomSheet(permission, context!);
      if (askForPermission ?? false) {
        await [permission].request();
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
}
