import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:web3_provider/web3_provider.dart';

import 'domain/entities/entities.dart' as entities;

class OpenDAppState with EquatableMixin {
  Account? account;
  InAppWebViewController? webviewController;
  AnimationController? animationController;
  int progress = 0;
  Network? network;
  int panelHideTimer = 5;
  Uri? currentUrl;
  bool isSecure = false;
  late DAppHooksModel dappHooksData;
  // this is used for controlling the onLoadStop not being called twice
  bool isLoadStopCalled = true;

  List<ScanResult> scanResults = [];
  
  entities.BluetoothDevice? selectedBluetoothDevice;

  @override
  List<Object?> get props => [
        account,
        webviewController,
        progress,
        network,
        animationController,
        currentUrl,
        isSecure,
        dappHooksData,
        isLoadStopCalled,
        scanResults
      ];
}
