import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/utils/utils.dart';
import 'package:flutter/material.dart';

import '../dapp_hooks_state.dart';
class DAppHooksHelper {
  DAppHooksHelper(
      {required this.state,
      required this.context,
      required this.translate});

  DAppHooksState state;
  DappHooksSnackBarUtils get dappHooksSnackBarUtils =>
      DappHooksSnackBarUtils(translate: translate, context: context);
  BuildContext? context;
  String? Function(String) translate;

  static Future<void> shouldUpdateWrapper(
      Future<bool> Function() execution, void Function() update) async {
    final executionResult = await execution();
    if (executionResult) {
      update();
    }
  }
}
