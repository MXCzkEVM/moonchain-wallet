import 'package:flutter/material.dart';
import 'package:mxc_logic/internal.dart';

abstract class GlobalCacheContainer {
  GlobalCacheContainer(this._cacheManager);

  final CacheManager _cacheManager;
  List<BaseCacheRepository> get repositories;

  @protected
  Future<void> loadGlobal() {
    return Future.wait(repositories
        .whereType<GlobalCacheStore>()
        .map((e) => e.load(_cacheManager)));
  }
}

abstract class CacheContainer extends GlobalCacheContainer {
  CacheContainer(CacheManager cacheManager) : super(cacheManager);

  late final CacheController controller =
      CacheController(_cacheManager, prefixKey);

  String get prefixKey;

  @protected
  void register() {
    repositories.whereType<ControlledCacheStore>().forEach(controller.register);
  }
}

abstract class BaseCacheRepository extends BaseCacheStore {}

abstract class ControlledCacheRepository extends ControlledCacheStore
    implements BaseCacheRepository {}

abstract class GlobalCacheRepository extends GlobalCacheStore
    implements BaseCacheRepository {}
