import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SplashENSQueryState with EquatableMixin {
  TextEditingController usernameController = TextEditingController();
  bool isRegistered = false;
  String? errorText;

  @override
  List<Object?> get props => [
        usernameController,
        isRegistered,
        errorText,
      ];
}
