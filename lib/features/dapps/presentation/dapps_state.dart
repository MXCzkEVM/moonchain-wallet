import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class DAppsState with EquatableMixin {
  List<Bookmark> bookmarks = [];
  int pageIndex = 0;
  bool isEditMode = false;
  bool gesturesInstructionEducated = false;

  List<Dapp> dapps = [];
  List<Dapp> dappsAndBookmarks = [];
  bool loading = false;

  Network? network;

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
      ];
}
