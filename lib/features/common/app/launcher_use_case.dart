import 'dart:async';
import 'dart:io';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:web3dart/web3dart.dart';

class LauncherUseCase extends ReactiveUseCase {
  LauncherUseCase(
    this._repository,
    this._accountUseCase,
    this._chainConfigurationUseCase,
  );

  final Web3Repository _repository;
  final AccountUseCase _accountUseCase;
  final ChainConfigurationUseCase _chainConfigurationUseCase;

  void viewTransactions() async {
    final chainExplorerUrl =
        _chainConfigurationUseCase.selectedNetwork.value!.explorerUrl!;
    final address = _accountUseCase.account.value!.address;
    final addressExplorer = Urls.addressExplorer(address);
    final launchUri = MXCFormatter.mergeUrl(chainExplorerUrl, addressExplorer);

    openUrl(launchUri, LaunchMode.platformDefault);
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
    final enabledNetwork = _chainConfigurationUseCase.selectedNetwork.value!;
    if (enabledNetwork.chainId == Config.mxcTestnetChainId) {
      return Urls.mxcTestnetNftMarketPlace;
    } else if (enabledNetwork.chainId == Config.mxcMainnetChainId) {
      return Urls.mxcMainnetNftMarketPlace;
    } else {
      return null;
    }
  }

  Future<void> launchEmailApp() async {
    await launchUrlInPlatformDefaultWithString(Urls.emailApp);
  }

  Future<bool> isEmailAppAvailable() async {
    final url = getUriFromString(Urls.emailApp);

    return await canLaunchUrl(url);
  }

  Future<void> launchMXCZendesk() async {
    await launchUrlInExternalAppWithString(Urls.mxcZendesk);
  }

  Future<void> launchMXCKnowledgeHub() async {
    await launchUrlInExternalAppWithString(Urls.mxcKnowledgeHub);
  }

  Future<void> launchMXCDesignDocs() async {
    await launchUrlInExternalAppWithString(Urls.mxcDesignDocs);
  }

  Future<void> launchAxsTermsConditions() async {
    await launchUrlInExternalAppWithString(Urls.axsTermsConditions);
  }

  void openTelegram() => launchUrlInPlatformDefaultWithString(Urls.telegram);

  void openWeChat() => launchUrlInPlatformDefaultWithString(Urls.weChat);

  void openAXSPrivacy(String path) async {
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
