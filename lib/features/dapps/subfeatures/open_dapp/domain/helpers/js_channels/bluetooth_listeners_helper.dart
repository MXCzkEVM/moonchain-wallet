import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/settings/subfeatures/dapp_hooks/dapp_hooks.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../../open_dapp.dart';

class BluetoothListenersHelper {
  BluetoothListenersHelper({
    required this.state,
    required this.context,
    required this.translate,
    required this.bluetoothHelper,
    required this.navigator,
    required this.minerHooksHelper,
    required this.jsChannelHandlerHelper,
  });

  OpenDAppState state;
  NavigatorState? navigator;
  MinerHooksHelper minerHooksHelper;
  BluetoothHelper bluetoothHelper;
  BuildContext? context;
  String? Function(String) translate;
  JsChannelHandlersHelper jsChannelHandlerHelper;

  void injectBluetoothListeners() {
    // Bluetooth API

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.requestDevice,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(
            args, bluetoothHelper.handleBluetoothRequestDevice));

    // BluetoothRemoteGATTServer

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.bluetoothRemoteGATTServerConnect,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(
            args, bluetoothHelper.handleBluetoothRemoteGATTServerConnect));

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.bluetoothRemoteGATTServerGetPrimaryService,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(args,
            bluetoothHelper.handleBluetoothRemoteGATTServerGetPrimaryService));

    // BluetoothRemoteGATTService

    state.webviewController!.addJavaScriptHandler(
        handlerName:
            JSChannelEvents.bluetoothRemoteGATTServiceGetCharacteristic,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(args,
            bluetoothHelper.handleBluetoothRemoteGATTServiceGetCharacteristic));

    // BluetoothRemoteGATTCharacteristic

    state.webviewController!.addJavaScriptHandler(
        handlerName:
            JSChannelEvents.bluetoothRemoteGATTCharacteristicStartNotifications,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(
            args,
            bluetoothHelper
                .handleBluetoothRemoteGATTCharacteristicStartNotifications));

    state.webviewController!.addJavaScriptHandler(
        handlerName:
            JSChannelEvents.bluetoothRemoteGATTCharacteristicStopNotifications,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(
            args,
            bluetoothHelper
                .handleBluetoothRemoteGATTCharacteristicStopNotifications));

    state.webviewController!.addJavaScriptHandler(
        handlerName:
            JSChannelEvents.bluetoothRemoteGATTCharacteristicWriteValue,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(args,
            bluetoothHelper.handleBluetoothRemoteGATTCharacteristicWriteValue));

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents
            .bluetoothRemoteGATTCharacteristicWriteValueWithResponse,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(
            args,
            bluetoothHelper
                .handleBluetoothRemoteGATTCharacteristicWriteValueWithResponse));

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents
            .bluetoothRemoteGATTCharacteristicWriteValueWithoutResponse,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(
            args,
            bluetoothHelper
                .handleBluetoothRemoteGATTCharacteristicWriteValueWithoutResponse));

    state.webviewController!.addJavaScriptHandler(
        handlerName: JSChannelEvents.bluetoothRemoteGATTCharacteristicReadValue,
        callback: (args) => jsChannelHandlerHelper.jsChannelErrorHandler(args,
            bluetoothHelper.handleBluetoothRemoteGATTCharacteristicReadValue));
  }
}
