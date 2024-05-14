import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/src/routing/route.dart';
import 'package:datadashwallet/features/dapps/subfeatures/add_dapp/domain/bookmark_use_case.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import '../subfeatures/add_dapp/presentation/add_bookmark.dart';

class BookMarksHelper {
  BookMarksHelper({
    required this.bookmarkUseCase,
    required this.navigator,
    required this.context,
    required this.translate,
  });
  BookmarkUseCase bookmarkUseCase;
  NavigatorState? navigator;
  BuildContext? context;
  String? Function(String) translate;

  void addBookmark() {
    navigator!.push(
      route.featureDialog(const AddBookmark()),
    );
  }

  void removeBookmarkDialog(Bookmark item, void Function() animation) async {
    final result = await showAlertDialog(
      context: context!,
      title: '${translate('remove')!} ${item.title}',
      content: translate('dapp_removal_dialog_text')!,
      ok: translate('delete')!,
    );

    if (result != null && result) {
      animation();
    }
  }

  void removeBookmark(Bookmark item) async {
    bookmarkUseCase.removeItem(item);
  }

  void getBookmarkFavicon(Bookmark item) {
    bookmarkUseCase.addItem(item);
  }

  void updateBookmarkFavIcon(Bookmark item) async {
    var iconUrl = await FaviconFinder.getBest(item.url);

    final updatedItem = item.copyWithBookmark(image: iconUrl?.url);
    bookmarkUseCase.updateItem(updatedItem);
  }
}
