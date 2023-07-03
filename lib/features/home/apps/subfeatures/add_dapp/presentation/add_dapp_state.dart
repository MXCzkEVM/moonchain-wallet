import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AddDAppPageState with EquatableMixin {
  TextEditingController urlController = TextEditingController();

  @override
  List<Object?> get props => [
        urlController,
      ];
}
