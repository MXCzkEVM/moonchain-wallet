import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/internal.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:moonchain_wallet/core/src/cached_types.dart';
import '../cache/datadash_cache.dart';
import '../cache/global_cache.dart';
export 'providers_aliases.dart';

part 'providers_loader.dart';

final navigatorKey = GlobalKey<NavigatorState>();

ValueNotifier<ProviderContainer> containerNotifier =
    ValueNotifier(ProviderContainer());

void resetProviders() => containerNotifier.value = ProviderContainer();

final Provider<DatadashSetupStore> datadashSetupProvider =
    Provider((ref) => _datadashSetupStore!);

final Provider<GlobalCache> globalCacheProvider =
    Provider((ref) => _globalCache!);

final Provider<DatadashCache> datadashCacheProvider =
    Provider((ref) => _datadashCache!);

final Provider<AuthenticationStorageRepository> authenticationStorageProvider =
    Provider((ref) => AuthenticationStorageRepository(_datadashSetupStore!));

final Provider<AuthenticationCacheRepository> authenticationCacheRepository =
    Provider(
  (ref) => AuthenticationCacheRepository(
    ref.watch(datadashCacheProvider).controller,
    ref.watch(authenticationStorageProvider),
  ),
);

final Provider<Web3Repository> web3RepositoryProvider = Provider(
  (ref) => Web3Repository(
    setupStore: ref.watch(datadashSetupProvider),
  ),
);
