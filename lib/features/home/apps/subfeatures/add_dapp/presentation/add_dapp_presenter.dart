import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mxc_ui/mxc_ui.dart';

import '../domain/bookmark_use_case.dart';

final addDAppPageContainer =
    PresenterContainer<AddDAppPresenter, void>(
        () => AddDAppPresenter());

class AddDAppPresenter extends CompletePresenter<void> {
  AddDAppPresenter() : super(null);

  late final BookmarkUseCase _bookmarksUseCase =
      ref.read(bookmarksUseCaseProvider);
  late final TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    // urlController.dispose();

    super.dispose();
  }

  Future<void> onSave() async {
    final url = urlController.text;

    try {
      final response = await http.get(Uri.parse(url));
      final startIndex = response.body.indexOf('<title>');
      final endIndex = response.body.indexOf('</title>');
      String title = response.body.substring(startIndex + 7, endIndex);

      if (startIndex == -1 || title.isEmpty) {
        title = 'Unknown';
      }

      _bookmarksUseCase.addItem(Bookmark(
        id: DateTime.now().microsecondsSinceEpoch,
        title: title,
        url: url,
      ));

      BottomFlowDialog.of(context!).close();
    } catch (e, s) {
      addError(e, s);
    }
  }
}
