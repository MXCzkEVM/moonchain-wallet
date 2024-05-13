import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class BookmarkRepository extends GlobalCacheRepository {
  @override
  final String zone = 'bookmarks';

  late final Field<List<Bookmark>> bookmarks = fieldWithDefault<List<Bookmark>>(
    'items',
    [],
    serializer: (t) => t
        .map((e) => {
              'id': e.id,
              'title': e.title,
              'url': e.url,
              'image': e.image,
              'description': e.description,
            })
        .toList(),
    deserializer: (t) => (t as List)
        .map((e) => Bookmark(
              id: e['id'],
              title: e['title'],
              url: e['url'],
              image: e['image'],
              description: e['description'],
            ))
        .toList(),
  );

  List<Bookmark> get items => bookmarks.value;

  void addItem(Bookmark item) => bookmarks.value = [...bookmarks.value, item];

  void updateItem(Bookmark item) {
    final newBookMarks = bookmarks.value;
    final itemIndex = newBookMarks.indexWhere((e) => e.url == item.url);

    newBookMarks[itemIndex] = item;
    bookmarks.value = newBookMarks;
  }

  void removeItem(Bookmark item) =>
      bookmarks.value = bookmarks.value.where((e) => e.id != item.id).toList();
}
