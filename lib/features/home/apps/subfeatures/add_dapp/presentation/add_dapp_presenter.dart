import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mxc_ui/mxc_ui.dart';

import '../domain/bookmark_use_case.dart';
import 'add_dapp_state.dart';

final addDAppPageContainer =
    PresenterContainer<AddDAppPresenter, AddDAppPageState>(
        () => AddDAppPresenter());

class AddDAppPresenter extends CompletePresenter<AddDAppPageState> {
  AddDAppPresenter() : super(AddDAppPageState());
  late final BookmarkUseCase _bookmarksUseCase =
      ref.read(bookmarksUseCaseProvider);

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    // state.urlController.dispose();

    super.dispose();
  }

  Future<void> onSave() async {
    final url = state.urlController.text;

    try {
      RegExp urlExp = RegExp(
          r"(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?");
      if (!urlExp.hasMatch(url)) throw Exception('Invalid format');

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
