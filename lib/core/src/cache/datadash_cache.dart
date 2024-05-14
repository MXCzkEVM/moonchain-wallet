import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/dapps/domain/domain.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/nft/domain/nfts_repository.dart';
import 'package:datadashwallet/features/settings/subfeatures/address_book/domain/recipients_repository.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/token/add_token/domain/custom_tokens_repository.dart';
import 'package:datadashwallet/features/dapps/subfeatures/add_dapp/domain/bookmark_repository.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/domain/dapp_hooks_repository.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/domain/background_fetch_config_repository.dart';
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
  final BackgroundFetchConfigRepository backgroundFetchConfigRepository =
      BackgroundFetchConfigRepository();
  final DAppHooksRepository dAppHooksRepository = DAppHooksRepository();
  final BalanceRepository balanceHistory = BalanceRepository();
  final RecipientsRepository recipients = RecipientsRepository();
  final DappsOrderRepository dappsOrderRepository = DappsOrderRepository();
  final NftsRepository nfts = NftsRepository();
  final TransactionsHistoryRepository transactionsHistoryRepository =
      TransactionsHistoryRepository();

  @override
  List<BaseCacheRepository> get repositories => [
        bookmarks,
        custonTokens,
        balanceHistory,
        recipients,
        dappsOrderRepository,
        nfts,
        transactionsHistoryRepository,
        backgroundFetchConfigRepository,
        dAppHooksRepository,
      ];
}
