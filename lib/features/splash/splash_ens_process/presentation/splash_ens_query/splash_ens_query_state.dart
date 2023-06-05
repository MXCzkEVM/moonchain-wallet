import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SplashENSQueryState with EquatableMixin {
  TextEditingController usernameController = TextEditingController();
  bool agreeChecked = false;
  bool isRegistered = false;

  @override
  List<Object?> get props => [
        usernameController,
        agreeChecked,
        isRegistered,
      ];
}
