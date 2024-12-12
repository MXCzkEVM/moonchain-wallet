import 'package:moonchain_wallet/features/common/account/account_cache_repository.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/dapps/domain/domain.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:mxc_logic/internal.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';

/// This is cache related to our entire app
/// It is implied that it should never be changed from outside as a result of any events.
/// (e.g. GlobalCache should not reload its data on different user sign in)
class GlobalCache extends GlobalCacheContainer {
  GlobalCache._(CacheManager cacheManager) : super(cacheManager);

  static Future<GlobalCache> load(CacheManager cacheManager) async {
    final cache = GlobalCache._(cacheManager);
    await cache.loadGlobal();
    return cache;
  }

  final ThemeCacheRepository theme = ThemeCacheRepository();
  final LanguageRepository language = LanguageRepository();
  final PasscodeRepository passcode = PasscodeRepository();
  final GesturesInstructionRepository gesturesInstruction =
      GesturesInstructionRepository();
  final ChainConfigurationRepository chainConfigurationRepository =
      ChainConfigurationRepository();
  final AccountCacheRepository account = AccountCacheRepository();
  final LogsConfigRepository logsConfigRepository = LogsConfigRepository();

  @override
  List<BaseCacheRepository> get repositories => [
        theme,
        language,
        passcode,
        gesturesInstruction,
        chainConfigurationRepository,
        account,
        logsConfigRepository,
      ];
}
