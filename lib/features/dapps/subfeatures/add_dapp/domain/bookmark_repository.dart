import 'package:datadashwallet/features/dapps/entities/bookmark.dart';
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
            })
        .toList(),
    deserializer: (t) => (t as List)
        .map((e) => Bookmark(
              id: e['id'],
              title: e['title'],
              url: e['url'],
            ))
        .toList(),
  );

  List<Bookmark> get items => bookmarks.value;

  void addItem(Bookmark item) => bookmarks.value = [...bookmarks.value, item];

  void removeItem(Bookmark item) =>
      bookmarks.value = bookmarks.value.where((e) => e.id != item.id).toList();
}
