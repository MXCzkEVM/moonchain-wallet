import 'dart:async';
import 'dart:io';

import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class LauncherUseCase extends ReactiveUseCase {
  LauncherUseCase(
    this._repository,
    this._accountUseCase,
    this._chainConfigurationUseCase,
  );

  final Web3Repository _repository;
  final AccountUseCase _accountUseCase;
  final ChainConfigurationUseCase _chainConfigurationUseCase;

  void viewTransactions(List<TransactionModel>? txList) async {
    // Account should have tx
    if (txList != null && txList.isNotEmpty) {
      final chainExplorerUrl =
          _chainConfigurationUseCase.selectedNetwork.value!.explorerUrl!;
      final address = _accountUseCase.account.value!.address;
      final ethAddress = EthereumAddress.fromHex(address);
      final addressExplorer = Urls.addressExplorer(ethAddress.hexEip55);
      final launchUri =
          MXCFormatter.mergeUrl(chainExplorerUrl, addressExplorer);

      openUrl(launchUri, LaunchMode.platformDefault);
    } else {
      final chainExplorerUrl = Uri.parse(
          _chainConfigurationUseCase.selectedNetwork.value!.explorerUrl!);
      openUrl(chainExplorerUrl, LaunchMode.platformDefault);
    }
  }

  /// Launches the given txHash in the chains explorer tx page
  void viewTransaction(String txHash) async {
    final chainExplorerUrl =
        _chainConfigurationUseCase.selectedNetwork.value!.explorerUrl!;
    final txExplorer = Urls.txExplorer(txHash);
    final launchUri = MXCFormatter.mergeUrl(chainExplorerUrl, txExplorer);

    openUrl(launchUri, LaunchMode.platformDefault);
  }

  void viewAddress(String address) async {
    final chainExplorerUrl =
        _chainConfigurationUseCase.selectedNetwork.value!.explorerUrl!;
    final addressExplorer = Urls.addressExplorer(address);
    final launchUri = MXCFormatter.mergeUrl(chainExplorerUrl, addressExplorer);

    if ((await canLaunchUrl(launchUri))) {
      await launchUrl(launchUri, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> openUrl(Uri url, LaunchMode launchMode) async {
    if ((await canLaunchUrl(url))) {
      await launchUrl(url, mode: launchMode);
    } else {
      throw UnimplementedError('Could not launch $url');
    }
  }

  Uri getUriFromString(String url) {
    return Uri.parse(url);
  }

  Future<void> launchUrlInPlatformDefaultWithString(String url) async {
    await launchUrlInPlatformDefault(getUriFromString(url));
  }

  Future<void> launchUrlInExternalAppWithString(String url) async {
    await launchUrlInExternalApp(getUriFromString(url));
  }

  Future<void> launchUrlInExternalApp(Uri url) async {
    await openUrl(url, LaunchMode.externalApplication);
  }

  Future<void> launchUrlInPlatformDefault(Uri url) async {
    await openUrl(url, LaunchMode.platformDefault);
  }

  String? getNftMarketPlaceUrl() {
    return _repository.launcherRepository.getNftMarketPlaceUrl();
  }

  Future<void> launchEmailApp() async {
    await launchUrlInPlatformDefaultWithString(Urls.emailApp);
  }

  Future<bool> isEmailAppAvailable() async {
    final url = getUriFromString(Urls.emailApp);

    return await canLaunchUrl(url);
  }

  Future<void> launchMoonchainSupportBot() async {
    await launchUrlInExternalAppWithString(Urls.moonchainSupportBot);
  }

  Future<void> launchMoonchainWebsite() async {
    await launchUrlInExternalAppWithString(Urls.moonchainWebsite);
  }

  Future<void> launchMoonchainDesignDocs() async {
    await launchUrlInExternalAppWithString(Urls.moonchainDesignDocs);
  }

  Future<void> launchMXCWalletTermsConditions() async {
    await launchUrlInExternalAppWithString(Urls.mxcWalletTermsConditions);
  }

  void openTelegram() => launchUrlInPlatformDefaultWithString(Urls.telegram);

  void openWeChat() => launchUrlInPlatformDefaultWithString(Urls.weChat);

  void openMXCWalletPrivacy(String path) async {
    ByteData data = await rootBundle.load(path);
    List<int> bytes = data.buffer.asUint8List();
    String tempDir = (await getTemporaryDirectory()).path;
    String tempFilePath = '$tempDir/${path.split('/').last}';
    File tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(bytes, flush: true);
    openFile(tempFilePath);
  }

  void openFile(String path) => OpenFile.open(path);
}
