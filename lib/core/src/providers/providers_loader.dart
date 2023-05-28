part of 'providers.dart';

GlobalCache? _globalCache;
UserSetupStore? _userSetupStore;

class _ProviderLoader {
  Future<CacheManager> getCacheManager() async {
    final applicationDocuments = await getApplicationDocumentsDirectory();
    final manager = await CacheManager.load(applicationDocuments.path);
    registerCacheTypes(manager);
    return manager;
  }

  Future<void> loadProviders() async {
    final cacheManager = await getCacheManager();
    _userSetupStore = UserSetupStore();
    await _userSetupStore!.load(cacheManager);

    _globalCache = await GlobalCache.load(cacheManager);
  }
}

Future<void> loadProviders() async {
  await _ProviderLoader().loadProviders();
}
