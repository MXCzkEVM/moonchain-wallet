import 'dart:async';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/json_rpc.dart';

class ErrorUseCase extends ReactiveUseCase {
  ErrorUseCase(this._repository, this._accountUseCase,
      this._chainConfigurationUseCase, this._launcherUseCase);

  final Web3Repository _repository;
  final AccountUseCase _accountUseCase;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final LauncherUseCase _launcherUseCase;

  /// If error is known & handled will return true, otherwise return false.
  bool handleError(
    BuildContext context,
    dynamic e,
    void Function(dynamic error, [StackTrace? stackTrace]) addError,
    String? Function(String key) translate,
  ) {
    if (e is RPCError) {
      return handlerRPCError(context, e.message, addError, translate);
    } else {
      return false;
    }
  }

  bool handleBackgroundServiceError(
    String notificationTitle,
    dynamic e,
  ) {
    if (e is RPCError && isRPCIgnoredError(e.message)) {
      return true;
    }

    AXSNotification().showNotification(
      notificationTitle,
      e.toString(),
    );
    return true;
  }
  // already known

  bool isRPCIgnoredError(String message) {
    bool isIgnored = false;
    for (String error in ErrorMessages.ignoredErrors) {
      if (message.contains(error)) {
        isIgnored = true;
        break;
      }
    }
    return isIgnored;
  }

  bool handlerRPCError(
    BuildContext context,
    String message,
    void Function(dynamic error, [StackTrace? stackTrace]) addError,
    String? Function(String key) translate,
  ) {
    final isFund = isFundError(message);

    if (isFund) {
      final network = _chainConfigurationUseCase.selectedNetwork.value!;
      final walletAddress = _accountUseCase.account.value!.address;
      showReceiveBottomSheet(
          context, walletAddress, network.chainId, network.symbol, () {
        l3Tap(context);
      }, _launcherUseCase.launchUrlInPlatformDefaultWithString, true);
      return isFund;
    }

    final errorMessage = checkErrorMessage(message);

    if (errorMessage != null) {
      addError(translate(errorMessage));
      return true;
    }

    return false;
  }

  bool isFundError(String message) {
    bool isError = false;
    for (String error in ErrorMessages.fundErrors) {
      if (message.contains(error)) {
        isError = true;
        break;
      }
    }
    return isError;
  }

  String? checkErrorMessage(String message) {
    List<String> errorList = ErrorMessages.errorList;

    for (String errorMessage in errorList) {
      if (message.contains(errorMessage)) {
        return ErrorMessages.errorMessageMapper[errorMessage];
      }
    }

    return null;
  }

  void l3Tap(BuildContext context) {
    final network = _chainConfigurationUseCase.selectedNetwork.value!;
    final chainId = network.chainId;
    final l3BridgeUri = Urls.networkL3Bridge(chainId);
    Navigator.of(context).push(route.featureDialog(
      maintainState: false,
      OpenAppPage(
        url: l3BridgeUri,
      ),
    ));
  }
}
