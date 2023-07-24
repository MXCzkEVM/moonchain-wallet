import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class AddNftState with EquatableMixin {
  bool valid = false;

  @override
  List<Object?> get props => [
        valid,
    ];
}
