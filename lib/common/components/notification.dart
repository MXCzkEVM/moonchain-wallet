import 'package:datadashwallet/core/core.dart';

showNotification(String title, String? text) {
  AXSNotification().showNotification(title, text);
}

showLowPriorityNotification(String title, String? text) {
  AXSNotification().showLowPriorityNotification(title, text);
}
