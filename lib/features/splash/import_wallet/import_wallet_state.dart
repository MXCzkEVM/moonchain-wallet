import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SplashImportWalletState with EquatableMixin {
  TextEditingController mnemonicController = TextEditingController();

  @override
  List<Object?> get props => [
        mnemonicController,
      ];
}
