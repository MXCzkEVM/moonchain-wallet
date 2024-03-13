import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';

class DappHooksSnackBarUtils {
  DappHooksSnackBarUtils({this.context, required this.translate});

  BuildContext? context;
  String? Function(String) translate;

  void showDAppHooksServiceFailureSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('unable_to_launch_service')!
            .replaceAll('{0}', translate('dapp_hooks')!),
        type: SnackBarType.fail);
  }

  void showLocationServiceServiceFailureSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('unable_to_launch_service')!
            .replaceAll('{0}', translate('location')!),
        type: SnackBarType.fail);
  }

  void showDAppHooksServiceSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('service_launched_successfully')!
            .replaceAll('{0}', translate('dapp_hooks')!));
  }

  void showDAppHooksServiceDisableSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('service_disabled_successfully')!
            .replaceAll('{0}', translate('dapp_hooks')!));
  }

  void showMinerHooksServiceFailureSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('unable_to_launch_service')!
            .replaceAll('{0}', translate('miner_hooks')!),
        type: SnackBarType.fail);
  }

  void showMinerHooksServiceSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('service_launched_successfully')!
            .replaceAll('{0}', translate('miner_hooks')!));
  }

  void showScheduleSnackBar(String time) {
    showSnackBar(
        context: context!,
        content:
            translate('auto_claim_scheduling_text')!.replaceAll('{0}', time));
  }

  void showMinerHooksServiceDisableSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('service_disabled_successfully')!
            .replaceAll('{0}', translate('miner_hooks')!));
  }
}
