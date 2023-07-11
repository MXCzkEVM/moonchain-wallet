import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/add_dapp/domain/bookmark_use_case.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/apps_page/domain/bookmark_pagination_use_case.dart';

import 'apps_page_state.dart';

final appsPagePageContainer =
    PresenterContainer<AppsPagePresenter, AppsPagePageState>(
        () => AppsPagePresenter());

class AppsPagePresenter extends CompletePresenter<AppsPagePageState> {
  AppsPagePresenter() : super(AppsPagePageState());

  late final BookmarkUseCase _bookmarksUseCase =
      ref.read(bookmarksUseCaseProvider);

  late final BookmarkPaginationUseCase _bookmarkPaginationUseCase =
      ref.read(bookmarkPaginationUseCaseProvider);

  @override
  void initState() {
    super.initState();

    PermissionUtils.requestAllPermissions();
    _bookmarkPaginationUseCase.resetPage();

    listen<List<Bookmark>>(
      _bookmarksUseCase.bookmarks,
      (v) => notify(() => state.bookmarks = v),
    );

    listen<List<int>>(
        _bookmarkPaginationUseCase.pages, (v) => notify(() => state.pages = v));
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void removeBookmark(Bookmark item) {
    _bookmarksUseCase.removeItem(item);
    _bookmarkPaginationUseCase.removePage();
  }

  void updatePage(int index, int num) =>
      _bookmarkPaginationUseCase.updatePage(index, num);

  void onPageChage(int index) => notify(() => state.pageIndex = index);

  void changeEditMode() => notify(() => state.isEditMode = !state.isEditMode);
  void resetEditMode() => notify(() => state.isEditMode = false);
}
