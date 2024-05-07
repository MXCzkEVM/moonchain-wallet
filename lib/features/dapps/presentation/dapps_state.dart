import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mxc_logic/mxc_logic.dart';

class DAppsState with EquatableMixin {
  List<Bookmark> bookmarks = [];
  int pageIndex = 0;
  bool isEditMode = false;
  bool gesturesInstructionEducated = false;

  List<Dapp> orderedDapps = [];
  List<String> dappsOrder = [];
  List<Dapp> dapps = [];
  List<Dapp> dappsAndBookmarks = [];
  bool dappsMerged = false;
  bool bookMarksMerged = false;
  bool loading = true;

  Network? network;

  Timer? timer;
  bool onLeftEdge = false;
  bool onRightEdge = false;

  @override
  List<Object?> get props => [
        bookmarks,
        pageIndex,
        isEditMode,
        gesturesInstructionEducated,
        dapps,
        dappsAndBookmarks,
        loading,
        network,
        dappsOrder,
        orderedDapps,
        dappsMerged,
        bookMarksMerged,
        timer,
        onLeftEdge,
        onRightEdge,
      ];
}
