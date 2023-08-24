import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/dapps/entities/bookmark.dart';
import 'package:flutter/services.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dapps_state.dart';
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
  late final _nftContractUseCase = ref.read(nftContractUseCaseProvider);
  late final _gesturesInstructionUseCase =
      ref.read(gesturesInstructionUseCaseProvider);

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    listen<List<Dapp>>(
      _dappStoreUseCase.dapps,
      (v) {
        state.dapps = v;
        state.dappsAndBookmarks.clear();
        state.dappsAndBookmarks = [...v, ...state.bookmarks];
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

    initializeDapps();
    initializeIpfsGateways();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void initializeDapps() async {
    notify(() => state.loading = true);
    try {
      await _dappStoreUseCase.getAllDapps();
    } catch (e, s) {
      addError(e, s);
    } finally {
      notify(() => state.loading = false);
    }
  }

  void initializeIpfsGateways() async {
    final List<String>? list = await getIpfsGateWays();

    if (list != null) {
      checkIpfsGateways(list);
    } else {
      initializeIpfsGateways();
    }
  }

  void removeBookmark(Bookmark item) {
    _bookmarksUseCase.removeItem(item);
  }

  void onPageChage(int index) => notify(() => state.pageIndex = index);

  void changeEditMode() => notify(() => state.isEditMode = !state.isEditMode);
  void resetEditMode() => notify(() => state.isEditMode = false);

  Future<List<String>?> getIpfsGateWays() async {
    List<String>? newList;
    try {
      newList = await _nftContractUseCase.getDefaultIpfsGateWays();
      _chainConfigurationUseCase.updateIpfsGateWayList(newList);
    } catch (e) {
      addError(e.toString());
    }

    return newList;
  }

  void checkIpfsGateways(List<String> list) async {
    for (int i = 0; i < list.length; i++) {
      final cUrl = list[i];
      final response = await _nftContractUseCase.checkIpfsGatewayStatus(cUrl);

      if (response != false) {
        _chainConfigurationUseCase.changeIpfsGateWay(cUrl);
        break;
      }
    }
  }

  void setGesturesInstruction() {
    _gesturesInstructionUseCase.setEducated(true);
  }

  Future<void> requestPermissions(Dapp dapp) async {
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
      await needPermissions.request();
      await PermissionUtils.permissionsStatus();
    }

  }

  void openDapp(String url) async {
    if (state.gesturesInstructionEducated) {
      openAppPage(context!, url);
    } else {
      final res = await showGesturesInstructionDialog(context!);

      if (res != null && res) {
        _gesturesInstructionUseCase.setEducated(true);
        openAppPage(context!, url);
      }
    }
  }
}
