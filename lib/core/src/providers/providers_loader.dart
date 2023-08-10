part of 'providers.dart';

DatadashCache? _datadashCache;
GlobalCache? _globalCache;
DatadashSetupStore? _datadashSetupStore;

class _ProviderLoader {
  Future<CacheManager> getCacheManager() async {
    final applicationDocuments = await getApplicationDocumentsDirectory();
    final manager = await CacheManager.load(applicationDocuments.path);
    registerCacheTypes(manager);
    return manager;
  }

  Future<void> loadProviders() async {
    final cacheManager = await getCacheManager();
    _datadashSetupStore = DatadashSetupStore();
    await _datadashSetupStore!.load(cacheManager);

    _datadashCache = await DatadashCache.load(
      cacheManager,
      _datadashSetupStore!.mnemonic?.split(' ').join(),
    );

    _globalCache = await GlobalCache.load(cacheManager);
  }
}

Future<void> loadProviders() async {
  await _ProviderLoader().loadProviders();
}
