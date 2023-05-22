import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/internal.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:datadashwallet/core/src/cached_types.dart';
import '../cache/global_cache.dart';
export 'providers_aliases.dart';

part 'providers_loader.dart';

final navigatorKey = GlobalKey<NavigatorState>();

ValueNotifier<ProviderContainer> containerNotifier =
    ValueNotifier(ProviderContainer());

void resetProviders() => containerNotifier.value = ProviderContainer();

final Provider<GlobalCache> globalCacheProvider =
    Provider((ref) => _globalCache!);

final Provider<ApiRepository> apiRepositoryProvider = Provider(
  (ref) => ApiRepository(),
);
