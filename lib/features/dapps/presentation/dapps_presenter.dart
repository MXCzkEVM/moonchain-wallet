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

    getIpfsGateWays();

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

  void getIpfsGateWays() async {
    try {
      final newList = await _tokenContractUseCase.getDefaultIpfsGateWays();
      _chainConfigurationUseCase.updateIpfsGateWayList(newList);
    } catch (e) {
      addError(e.toString());
    }
  }
}
