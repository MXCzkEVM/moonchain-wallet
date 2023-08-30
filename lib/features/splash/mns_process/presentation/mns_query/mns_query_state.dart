import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SplashMNSQueryState with EquatableMixin {
  bool isRegistered = false;
  String? errorText;
  String? walletAddress;
  bool checking = false;

  @override
  List<Object?> get props => [
        isRegistered,
        errorText,
        walletAddress,
        checking,
      ];
}
