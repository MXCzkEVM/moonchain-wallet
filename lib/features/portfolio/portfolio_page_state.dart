import 'package:equatable/equatable.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3dart/web3dart.dart';

class PortfolioState with EquatableMixin {
  String walletBalance = "0.0";

  List<Token>? tokensList;

  String? walletAddress;

  bool isWalletAddressCopied = false;

  @override
  List<Object?> get props => [walletBalance, tokensList, isWalletAddressCopied];
}
