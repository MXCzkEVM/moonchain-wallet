import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';

class NotificationsHooksSnackBarUtils {
  NotificationsHooksSnackBarUtils({this.context, required this.translate});

  BuildContext? context;
  String? Function(String) translate;

  void showBGFetchFailureSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('unable_to_launch_service')!
            .replaceAll('{0}', translate('background_notifications')!)
            .toLowerCase(),
        type: SnackBarType.fail);
  }

  void showBGFetchSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('service_launched_successfully')!
            .replaceAll('{0}', translate('background_notifications')!));
  }

  void showBGNotificationsDisableSuccessSnackBar() {
    showSnackBar(
        context: context!,
        content: translate('service_disabled_successfully')!
            .replaceAll('{0}', translate('background_notifications')!));
  }

}
