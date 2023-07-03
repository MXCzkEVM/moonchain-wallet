import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';

import 'bookmark_repository.dart';

class BookmarkUseCase extends ReactiveUseCase {
  BookmarkUseCase(this._repository);

  final BookmarkRepository _repository;

  late final ValueStream<List<Bookmark>> bookmarks =
      reactiveField(_repository.bookmarks);

  void addItem(Bookmark item) {
    _repository.addItem(item);
    update(bookmarks, _repository.items);
  }

  void removeItem(Bookmark item) {
    _repository.removeItem(item);
    update(bookmarks, _repository.items);
  }
}
