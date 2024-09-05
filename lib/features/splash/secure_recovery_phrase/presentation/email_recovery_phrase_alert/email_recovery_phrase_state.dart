import 'package:equatable/equatable.dart';
import 'package:datadashwallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/material.dart';

class EmailRecoveryPhrasetState extends RecoveryPhraseBaseState
    with EquatableMixin {
  String to = '';
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  List<Object?> get props => [
        super.props,
        to,
        formKey
      ];
}
