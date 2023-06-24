import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SplashImportWalletState with EquatableMixin {
  TextEditingController mnemonicController = TextEditingController();
  String? errorText;

  @override
  List<Object?> get props => [
        mnemonicController,
        errorText,
      ];
}
