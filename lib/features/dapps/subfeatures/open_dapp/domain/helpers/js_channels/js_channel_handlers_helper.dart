import 'dart:convert';

import 'package:moonchain_wallet/features/common/packages/bluetooth/bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../../open_dapp.dart';

class JsChannelHandlersHelper {
  JsChannelHandlersHelper({
    required this.state,
    required this.context,
    required this.translate,
    required this.addError,
  });

  OpenDAppState state;
  BuildContext? context;
  String? Function(String) translate;
  void Function(dynamic error, [StackTrace? stackTrace]) addError;

  Future<Map<String, dynamic>> jsChannelCronErrorHandler(
    List<dynamic> args,
    Future<Map<String, dynamic>> Function(
      Map<String, dynamic>,
      AXSCronServices,
    ) callback,
  ) async {
    try {
      Map<String, dynamic> channelDataMap;

      final channelData = args[0];
      channelDataMap = channelData as Map<String, dynamic>;

      final axsCronService =
          AXSCronServicesExtension.getCronServiceFromJson(channelDataMap);
      final callbackRes = await callback(
        channelDataMap,
        axsCronService,
      );
      return callbackRes;
    } catch (e) {
      final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
          status: AXSJSChannelResponseStatus.failed,
          data: null,
          message: e.toString());
      return response.toMap((data) => {'message': e.toString()});
    }
  }

  Future<dynamic> jsChannelErrorHandler(
    List<dynamic> args,
    Future<dynamic> Function(
      Map<String, dynamic>,
      BuildContext? context,
    ) callback,
  ) async {
    try {
      Map<String, dynamic> channelDataMap;

      final channelData = args.isNotEmpty ? args[0] : null;
      channelDataMap = channelData == null
          ? {}
          : channelData is String
              ? json.decode(channelData) as Map<String, dynamic>
              : channelData as Map<String, dynamic>;

      final callbackRes = await callback(channelDataMap, context);
      return callbackRes;
    } catch (e) {
      if (e is BluetoothTimeoutError) {
        addError(translate('unable_to_continue_bluetooth_is_turned_off')!);
      }

      final response = AXSJSChannelResponseModel<String>(
          status: AXSJSChannelResponseStatus.failed,
          data: null,
          message: e.toString());
      return response.toMap((data) => {'message': e});
    }
  }
}
