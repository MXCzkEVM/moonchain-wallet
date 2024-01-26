import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

class DAppHooksState with EquatableMixin {
  DAppHooksModel? dAppHooksData;
  Network? network;

  @override
  List<Object?> get props => [network, dAppHooksData];
}
