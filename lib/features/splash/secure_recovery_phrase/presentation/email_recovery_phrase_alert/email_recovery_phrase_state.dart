import 'package:equatable/equatable.dart';
import 'package:moonchain_wallet/features/splash/secure_recovery_phrase/secure_recovery_phrase.dart';
import 'package:flutter/material.dart';

class EmailRecoveryPhrasetState extends RecoveryPhraseBaseState
    with EquatableMixin {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  List<Object?> get props => [super.props, formKey];
}
