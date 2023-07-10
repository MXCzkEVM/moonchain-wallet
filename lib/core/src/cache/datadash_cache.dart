import 'package:datadashwallet/features/home/add_token/domain/custom_tokens_repository.dart';
import 'package:datadashwallet/features/home/apps/subfeatures/add_dapp/domain/bookmark_repository.dart';
import 'package:mxc_logic/internal.dart';

import 'base_cache.dart';

/// This is cache related to our current user
/// Every user have his own data repository.
/// Switching cache between users is controlled by `cacheController`.
class DatadashCache extends CacheContainer {
  DatadashCache._(CacheManager cacheManager) : super(cacheManager);

  static Future<DatadashCache> load(
      CacheManager cacheManager, String? username) async {
    final cache = DatadashCache._(cacheManager);
    cache.register();
    await cache.loadGlobal();
    if (username != null) await cache.controller.load(username);
    return cache;
  }

  @override
  final String prefixKey = 'datadash';

  final BookmarkRepository bookmarks = BookmarkRepository();
  final CustomTokensRepository custonTokens = CustomTokensRepository();

  @override
  List<BaseCacheRepository> get repositories => [
        bookmarks,
        custonTokens,
      ];
}
