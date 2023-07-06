import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mxc_ui/mxc_ui.dart';

import 'add_token_state.dart';

final addTokenPageContainer =
    PresenterContainer<AddTokenPresenter, AddTokenPageState>(
        () => AddTokenPresenter());

class AddTokenPresenter extends CompletePresenter<AddTokenPageState> {
  AddTokenPresenter() : super(AddTokenPageState());


  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  Future<void> onSave() async {

    try {
      
    } catch (e, s) {
      addError(e, s);
    }
  }
}
