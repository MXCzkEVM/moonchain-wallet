import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

class NotificationsState with EquatableMixin {
  bool isNotificationsEnabled = false;
  PeriodicalCallData? periodicalCallData;
  Network? network;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  List<Object?> get props =>
      [isNotificationsEnabled, periodicalCallData, network, formKey];
}
