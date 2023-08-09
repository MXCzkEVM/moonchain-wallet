import 'package:datadashwallet/features/dapps/entities/bookmark.dart';
import 'package:equatable/equatable.dart';

class DAppsState with EquatableMixin {
  List<Bookmark> bookmarks = [];
  int pageIndex = 0;
  bool isEditMode = false;
  bool gesturesInstructionEducated = false;

  @override
  List<Object?> get props => [
        bookmarks,
        pageIndex,
        isEditMode,
        gesturesInstructionEducated,
      ];
}
