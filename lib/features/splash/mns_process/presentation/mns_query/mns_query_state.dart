import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

class SplashMNSQueryState with EquatableMixin {
  bool isRegistered = false;
  String? errorText;
  String? walletAddress;
  bool checking = false;
  Network? network;

  @override
  List<Object?> get props => [
        isRegistered,
        errorText,
        walletAddress,
        checking,
      ];
}
