import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/common/components/recent_transactions/domain/mxc_transaction_use_case.dart';
import 'package:moonchain_wallet/features/common/account/log_out_use_case.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/dapps/domain/domain.dart';
import 'package:moonchain_wallet/features/errors/network_unavailable/network_unavailable_use_case.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/domain/nfts_use_case.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/token/add_token/domain/domain.dart';
import 'package:moonchain_wallet/features/settings/domain/app_version_use_case.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/address_book/address_book.dart';
import 'package:moonchain_wallet/features/dapps/subfeatures/add_dapp/domain/bookmark_use_case.dart';
import 'package:moonchain_wallet/features/portfolio/domain/portfolio_use_case.dart';
import 'package:moonchain_wallet/features/security/security.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/domain/dapp_hooks_use_case.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/notifications/domain/background_fetch_config_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/settings.dart';
import 'package:mxc_logic/mxc_logic.dart';

final Provider<ThemeUseCase> themeUseCaseProvider = Provider(
  (ref) => ThemeUseCase(
    ref.watch(globalCacheProvider).theme,
  ),
);

final Provider<LanguageUseCase> languageUseCaseProvider = Provider(
  (ref) => LanguageUseCase(ref.watch(globalCacheProvider).language),
);

final Provider<ContextLessTranslationUseCase>
    contextLessTranslationUseCaseProvider = Provider(
  (ref) => ContextLessTranslationUseCase(
    ref.watch(languageUseCaseProvider),
  ),
);

final Provider<GesturesInstructionUseCase> gesturesInstructionUseCaseProvider =
    Provider(
  (ref) => GesturesInstructionUseCase(
      ref.watch(globalCacheProvider).gesturesInstruction),
);

final Provider<DappsOrderUseCase> dappsOrderUseCaseProvider = Provider(
  (ref) =>
      DappsOrderUseCase(ref.watch(datadashCacheProvider).dappsOrderRepository),
);

final Provider<TokenContractUseCase> tokenContractUseCaseProvider = Provider(
  (ref) => TokenContractUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(accountUseCaseProvider),
    ref.watch(functionUseCaseProvider),
  ),
);

final Provider<TransactionControllerUseCase>
    transactionControllerUseCaseProvider = Provider(
  (ref) => TransactionControllerUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<NftContractUseCase> nftContractUseCaseProvider = Provider(
  (ref) => NftContractUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<TweetsUseCase> tweetsUseCaseProvider = Provider(
  (ref) => TweetsUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<MinerUseCase> minerUseCaseProvider = Provider(
  (ref) => MinerUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(contextLessTranslationUseCaseProvider),
  ),
);

final Provider<PricingUseCase> pricingUseCaseProvider = Provider(
  (ref) => PricingUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<PortfolioUseCase> portfolioUseCaseProvider = Provider(
  (ref) => PortfolioUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<PasscodeUseCase> passcodeUseCaseProvider = Provider(
  (ref) => PasscodeUseCase(ref.watch(globalCacheProvider).passcode),
);

final Provider<AuthUseCase> authUseCaseProvider = Provider(
  (ref) => AuthUseCase(
    ref.watch(web3RepositoryProvider).walletAddress,
    ref.watch(authenticationStorageProvider),
    ref.watch(authenticationCacheRepository),
  ),
);

final Provider<DirectoryUseCase> directoryUseCaseProvider = Provider(
  (ref) => DirectoryUseCase(),
);

final Provider<AccountUseCase> accountUseCaseProvider = Provider(
  (ref) => AccountUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(globalCacheProvider).account,
    ref.watch(authenticationStorageProvider),
  ),
);

final Provider<BookmarkUseCase> bookmarksUseCaseProvider = Provider(
  (ref) => BookmarkUseCase(ref.watch(datadashCacheProvider).bookmarks),
);

final Provider<BackgroundFetchConfigUseCase>
    backgroundFetchConfigUseCaseProvider = Provider(
  (ref) => BackgroundFetchConfigUseCase(
    ref.watch(datadashCacheProvider).backgroundFetchConfigRepository,
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(tokenContractUseCaseProvider),
    ref.watch(contextLessTranslationUseCaseProvider),
  ),
);

final Provider<DAppHooksUseCase> dAppHooksUseCaseProvider = Provider(
  (ref) => DAppHooksUseCase(
    ref.watch(datadashCacheProvider).dAppHooksRepository,
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(tokenContractUseCaseProvider),
    ref.watch(minerUseCaseProvider),
    ref.watch(
      accountUseCaseProvider,
    ),
    ref.watch(errorUseCaseProvider),
    ref.watch(contextLessTranslationUseCaseProvider),
    ref.watch(blueberryRingBackgroundSyncUseCase),
  ),
);

final Provider<BalanceUseCase> balanceHistoryUseCaseProvider = Provider(
  (ref) => BalanceUseCase(ref.watch(datadashCacheProvider).balanceHistory),
);

final Provider<RecipientsUseCase> recipientsCaseProvider = Provider(
  (ref) => RecipientsUseCase(ref.watch(datadashCacheProvider).recipients),
);

final Provider<NftsUseCase> nftsUseCaseProvider = Provider(
  (ref) => NftsUseCase(ref.watch(datadashCacheProvider).nfts),
);

final Provider<ChainConfigurationUseCase> chainConfigurationUseCaseProvider =
    Provider(
  (ref) => ChainConfigurationUseCase(
    ref.watch(globalCacheProvider).chainConfigurationRepository,
    ref.watch(authUseCaseProvider),
  ),
);

final Provider<TransactionsHistoryUseCase> transactionHistoryUseCaseProvider =
    Provider(
  (ref) => TransactionsHistoryUseCase(
    ref.watch(datadashCacheProvider).transactionsHistoryRepository,
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
  ),
);

final Provider<NetworkUnavailableUseCase> networkUnavailableUseCaseProvider =
    Provider(
  (ref) => NetworkUnavailableUseCase(),
);

final Provider<LogOutUseCase> logOutUseCaseProvider = Provider(
  (ref) => LogOutUseCase(
    accountCacheRepository: ref.watch(globalCacheProvider).account,
    authUseCase: ref.watch(authUseCaseProvider),
    passcodeUseCase: ref.watch(passcodeUseCaseProvider),
    webviewUseCase: WebviewUseCase(),
  ),
);

final Provider<DappStoreUseCase> dappStoreUseCaseProvider = Provider(
  (ref) => DappStoreUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<AppVersionUseCase> appVersionUseCaseProvider = Provider(
  (ref) => AppVersionUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<ChainsUseCase> chainsUseCaseProvider = Provider(
  (ref) => ChainsUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(authUseCaseProvider),
  ),
);

final Provider<ErrorUseCase> errorUseCaseProvider = Provider(
  (ref) => ErrorUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(accountUseCaseProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(launcherUseCaseProvider),
  ),
);

final Provider<FunctionUseCase> functionUseCaseProvider = Provider(
  (ref) => FunctionUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
  ),
);

final Provider<LauncherUseCase> launcherUseCaseProvider = Provider(
  (ref) => LauncherUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(accountUseCaseProvider),
    ref.watch(chainConfigurationUseCaseProvider),
  ),
);

final Provider<LogsConfigUseCase> logsConfigUseCaseProvider = Provider(
  (ref) => LogsConfigUseCase(
    ref.watch(globalCacheProvider).logsConfigRepository,
  ),
);

final Provider<CustomTokensUseCase> customTokensUseCaseProvider = Provider(
  (ref) => CustomTokensUseCase(
    ref.watch(globalCacheProvider).globalCustomTokensRepository,
    ref.watch(datadashCacheProvider).custonTokens,
    ref.watch(accountUseCaseProvider),
  ),
);

final Provider<MoonchainAppLinksUseCase> appLinksUseCaseProvider = Provider(
  (ref) => MoonchainAppLinksUseCase(
    ref.watch(authUseCaseProvider),
    ref.watch(passcodeUseCaseProvider),
  ),
);

final Provider<MoonchainNotificationsUseCase> notificationUseCaseProvider = Provider(
  (ref) => MoonchainNotificationsUseCase(
    ref.watch(appLinksUseCaseProvider),
  ),
);

final Provider<MXCTransactionsUseCase> mxcTransactionsUseCaseProvider =
    Provider(
  (ref) => MXCTransactionsUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(tokenContractUseCaseProvider),
  ),
);

final Provider<MXCWebsocketUseCase> mxcWebsocketUseCaseProvider = Provider(
  (ref) => MXCWebsocketUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(accountUseCaseProvider),
    ref.watch(functionUseCaseProvider),
  ),
);

final Provider<IPFSUseCase> ipfsUseCaseProvider = Provider(
  (ref) => IPFSUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
  ),
);

final Provider<BluetoothUseCase> bluetoothUseCaseProvider = Provider(
  (ref) => BluetoothUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(authUseCaseProvider),
  ),
);

final Provider<GoogleDriveUseCase> googleDriveUseCaseProvider = Provider(
  (ref) => GoogleDriveUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<ICloudUseCase> iCloudUseCaseProvider = Provider(
  (ref) => ICloudUseCase(
    ref.watch(web3RepositoryProvider),
  ),
);

final Provider<BlueberryRingUseCase> blueberryRingUseCaseProvider = Provider(
  (ref) => BlueberryRingUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(bluetoothUseCaseProvider),
  ),
);

final Provider<BlueberryRingBackgroundNotificationsUseCase>
    blueberryRingBackgroundNotificationsUseCaseProvider = Provider(
  (ref) => BlueberryRingBackgroundNotificationsUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(bluetoothUseCaseProvider),
    ref.watch(blueberryRingUseCaseProvider),
    ref.watch(contextLessTranslationUseCaseProvider),
  ),
);

final Provider<BlueberryRingBackgroundSyncUseCase>
    blueberryRingBackgroundSyncUseCase = Provider(
  (ref) => BlueberryRingBackgroundSyncUseCase(
    ref.watch(web3RepositoryProvider),
    ref.watch(chainConfigurationUseCaseProvider),
    ref.watch(bluetoothUseCaseProvider),
    ref.watch(blueberryRingUseCaseProvider),
    ref.watch(accountUseCaseProvider),
    ref.watch(contextLessTranslationUseCaseProvider),
  ),
);
