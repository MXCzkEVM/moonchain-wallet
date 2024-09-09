import 'package:datadashwallet/core/core.dart';

showNotification(String title, String? text) {
  MXCWalletNotification().showNotification(title, text);
}

showLowPriorityNotification(String title, String? text) {
  MXCWalletNotification().showLowPriorityNotification(title, text);
}
