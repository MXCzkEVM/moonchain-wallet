import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/entities/bookmark.dart';
import 'package:datadashwallet/features/dapps/subfeatures/add_dapp/domain/bookmark_use_case.dart';

import 'dapps_state.dart';

final appsPagePageContainer =
    PresenterContainer<DAppsPagePresenter, DAppsState>(
        () => DAppsPagePresenter());

class DAppsPagePresenter extends CompletePresenter<DAppsState> {
  DAppsPagePresenter() : super(DAppsState());

  late final BookmarkUseCase _bookmarksUseCase =
      ref.read(bookmarksUseCaseProvider);
  late final _chainConfigurationUseCase =
      ref.read(chainConfigurationUseCaseProvider);
  late final _tokenContractUseCase = ref.read(tokenContractUseCaseProvider);

  @override
  void initState() {
    super.initState();

    initializeIpfsGateways();

    PermissionUtils.requestAllPermissions();

    listen<List<Bookmark>>(
      _bookmarksUseCase.bookmarks,
      (v) {
        List<Bookmark> allBookmarks = [...Bookmark.fixedBookmarks(), ...v];

        notify(() => state.bookmarks = allBookmarks);
      },
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void removeBookmark(Bookmark item) {
    _bookmarksUseCase.removeItem(item);
  }

  void onPageChage(int index) => notify(() => state.pageIndex = index);

  void changeEditMode() => notify(() => state.isEditMode = !state.isEditMode);
  void resetEditMode() => notify(() => state.isEditMode = false);

  void initializeIpfsGateways() async {
    final List<String>? list = await getIpfsGateWays();

    if (list != null) {
      checkIpfsGateways(list);
    } else {
      initializeIpfsGateways();
    }
  }

  Future<List<String>?> getIpfsGateWays() async {
    List<String>? newList;
    try {
      newList = await _tokenContractUseCase.getDefaultIpfsGateWays();
      _chainConfigurationUseCase.updateIpfsGateWayList(newList);
    } catch (e) {
      addError(e.toString());
    }

    return newList;
  }

  void checkIpfsGateways(List<String> list) async {
    for (int i = 0; i < list.length; i++) {
      final cUrl = list[i];
      final response = await _tokenContractUseCase.checkIpfsGatewayStatus(cUrl);

      if (response != false) {
        _chainConfigurationUseCase.changeIpfsGateWay(cUrl);
        break;
      }
    }
  }
}
