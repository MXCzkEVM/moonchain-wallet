import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'bookmark_repository.dart';

class BookmarkUseCase extends ReactiveUseCase {
  BookmarkUseCase(this._repository);

  final BookmarkRepository _repository;

  late final ValueStream<List<Bookmark>> bookmarks =
      reactiveField(_repository.bookmarks);

  List<Bookmark> getBookmarks() => _repository.items;

  void addItem(Bookmark item) {
    _repository.addItem(item);
    update(bookmarks, _repository.items);
  }

  void updateItem(Bookmark item) {
    _repository.updateItem(item);
    update(bookmarks, _repository.items);
  }

  void removeItem(Bookmark item) {
    _repository.removeItem(item);
    update(bookmarks, _repository.items);
  }
}
