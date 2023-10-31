import 'dart:async';

import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/json_rpc.dart';

class ErrorUseCase extends ReactiveUseCase {
  ErrorUseCase(
    this._repository,
    this._accountUseCase,
    this._chainConfigurationUseCase,
  );

  final Web3Repository _repository;
  final AccountUseCase _accountUseCase;
  final ChainConfigurationUseCase _chainConfigurationUseCase;

  handleError(BuildContext context, dynamic e, {VoidCallback? onL3Tap}) {
    if (e is RPCError) {
      handlerRPCError(context, e.message, onL3Tap!);
    }
  }

  Future<void> handlerRPCError(
      BuildContext context, String message, VoidCallback onL3Tap) async {
    for (String error in Config.fundErrors) {
      if (message.contains(error)) {
        final network = _chainConfigurationUseCase.selectedNetwork.value!;
        final walletAddress = _accountUseCase.account.value!.address;
        showReceiveBottomSheet(
          context,
          walletAddress,
          network.chainId,
          network.symbol,
          onL3Tap,
          _chainConfigurationUseCase.launchUrlInPlatformDefault,
        );
        break;
      }
    }

    // String errorMessage = message;
    // errorMessage = changeErrorMessage(errorMessage);
    // addError(errorMessage);
  }

  // String _changeErrorMessage(String message) {
  //   if (message.contains('gas required exceeds allowance')) {
  //     return translate('insufficient_balance_for_fee') ?? message;
  //   }
  //   return message;
  // }
}
