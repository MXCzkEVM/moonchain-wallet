import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/account/account_cache_repository.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/nfts/domain/nfts_repository.dart';
import 'package:datadashwallet/features/settings/subfeatures/recipient/domain/recipients_repository.dart';
import 'package:datadashwallet/features/token/add_token/domain/custom_tokens_repository.dart';
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

  final AccountCacheRepository account = AccountCacheRepository();
  final BookmarkRepository bookmarks = BookmarkRepository();
  final CustomTokensRepository custonTokens = CustomTokensRepository();
  final BalanceRepository balanceHistory = BalanceRepository();
  final RecipientsRepository recipients = RecipientsRepository();
  final NftsRepository nfts = NftsRepository();

  @override
  List<BaseCacheRepository> get repositories => [
        account,
        bookmarks,
        custonTokens,
        balanceHistory,
        recipients,
        nfts,
      ];
}
