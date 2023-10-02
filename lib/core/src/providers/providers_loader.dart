part of 'providers.dart';

DatadashCache? _datadashCache;
GlobalCache? _globalCache;
DatadashSetupStore? _datadashSetupStore;
CacheManager? _cacheManager;

class _ProviderLoader {
  Future<CacheManager> getCacheManager() async {
    final applicationDocuments = await getApplicationDocumentsDirectory();
    final manager = await CacheManager.load(applicationDocuments.path);
    registerCacheTypes(manager);
    return manager;
  }

  Future<void> loadProviders() async {
    _cacheManager = await getCacheManager();
    _datadashSetupStore = DatadashSetupStore();
    await _datadashSetupStore!.load(_cacheManager!);

    final currentNetwork = _datadashSetupStore?.getNetwork ??
        Network.fixedNetworks().where((item) => item.enabled).first;
    final username =
        '${currentNetwork.chainId}_${_datadashSetupStore?.publicAddress}';

    _datadashCache = await DatadashCache.load(
      _cacheManager!,
      username,
    );

    _globalCache = await GlobalCache.load(_cacheManager!);
  }

  Future<void> loadDataDashProviders() async {
    final currentNetwork = _datadashSetupStore?.getNetwork ??
        Network.fixedNetworks().where((item) => item.enabled).first;
    final username =
        '${currentNetwork.chainId}_${_datadashSetupStore?.publicAddress}';

    _datadashCache = await DatadashCache.load(
      _cacheManager!,
      username,
    );
  }
}

Future<void> loadProviders() async {
  await _ProviderLoader().loadProviders();
}

Future<void> loadDataDashProviders(Network network) async {
  _datadashSetupStore!.network = network;
  await _ProviderLoader().loadDataDashProviders();
}
