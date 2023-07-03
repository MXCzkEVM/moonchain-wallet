import 'package:datadashwallet/common/utils/utils.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/add_dapp/domain/bookmark_use_case.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/apps_tab/domain/bookmark_pagination_use_case.dart';

import 'apps_tab_state.dart';

final appsTabPageContainer =
    PresenterContainer<AppsTabPresenter, AppsTabPageState>(
        () => AppsTabPresenter());

class AppsTabPresenter extends CompletePresenter<AppsTabPageState> {
  AppsTabPresenter() : super(AppsTabPageState());

  late final BookmarkUseCase _bookmarksUseCase =
      ref.read(bookmarksUseCaseProvider);

  late final BookmarkPaginationUseCase _bookmarkPaginationUseCase =
      ref.read(bookmarkPaginationUseCaseProvider);

  @override
  void initState() {
    super.initState();

    PermissionUtils.requestAllPermissions();

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
}
