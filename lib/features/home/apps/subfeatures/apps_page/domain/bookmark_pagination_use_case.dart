import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/add_dapp/domain/bookmark_repository.dart';
import 'package:collection/collection.dart';

class BookmarkPaginationUseCase extends ReactiveUseCase {
  BookmarkPaginationUseCase(this._repository);

  final BookmarkRepository _repository;

  late final ValueStream<List<int>> pages = reactive([]);

  List<int> get items => pages.value;

  void addPage(int num) {
    items.add(num);
    update(pages, items);
  }

  void updatePage(int index, int num) {
    if (index >= items.length) {
      items.add(num);
    } else {
      items[index] = num;
    }

    update(pages, items);

    nextPage(index, num);
  }

  void nextPage(int index, int count) {
    final total = _repository.items.length;

    int rowCount = 0;
    int leftpages = 0;

    for (int index = 0; index < items.length; index++) {
      rowCount += items[index];
    }

    leftpages = total - rowCount * 4;

    if (leftpages >= 1) {
      if (index + 1 >= items.length) {
        items.add(1);
      } else {
        items[index] = count;
      }
    }

    update(pages, items);
  }

  void removePage() {
    if (items.length == 1) return;

    final total = _repository.items.length;
    int rowCount = 0;
    int leftpages = 0;

    for (int index = 0; index < items.length - 1; index++) {
      rowCount += items[index];
    }

    leftpages = total - rowCount * 4;

    if (leftpages == 0) {
      items.removeLast();
      update(pages, items);
    }
  }

  void resetPage() {
    items.clear();
    update(pages, items);
  }
}
