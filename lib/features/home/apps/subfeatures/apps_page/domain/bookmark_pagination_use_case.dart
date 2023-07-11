import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/add_dapp/domain/bookmark_repository.dart';

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
    if (items.isEmpty) {
      items.add(num);
    } else {
      items[index] = num;
    }

    update(pages, items);

    nextPage(index, num);
  }

  void nextPage(int index, int count) {
    final total = _repository.items.length;
    if (total - count * 4 >= 1) {
      if (items.length == index + 1) {
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
    int currentRowCount = 0;
    int leftpages = 0;

    for (int index = 0; index < items.length - 1; index++) {
      currentRowCount += items[index];
    }

    leftpages = total - currentRowCount * 4;

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
