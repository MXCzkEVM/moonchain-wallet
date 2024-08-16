import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/dapp_hooks/dapp_hooks.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';

import '../../../open_dapp.dart';

class CronHelper {
  CronHelper({
    required this.state,
    required this.context,
    required this.translate,
    required this.dAppHooksUseCase,
    required this.navigator,
    required this.minerHooksHelper,
  });

  OpenDAppState state;
  DAppHooksUseCase dAppHooksUseCase;
  NavigatorState? navigator;
  MinerHooksHelper minerHooksHelper;
  BuildContext? context;
  String? Function(String) translate;

  // Update via functions & get data via steam & send the data via event eaach time
  // ready => updateSystemInfo (service statues, mining service status, time, selected miners, camera permission location permission)

  Future<Map<String, dynamic>> handleChangeCronTransition(
      Map<String, dynamic> channelData, AXSCronServices axsCronService) async {
    final axsCronService =
        AXSCronServicesExtension.getCronServiceFromJson(channelData);
    if (axsCronService == AXSCronServices.miningAutoClaimCron) {
      ChangeCronTransitionRequestModel;
      final changeCronTransitionRequestModel =
          ChangeCronTransitionRequestModel<MiningCronServiceDataModel>.fromMap(
              channelData['cron'], MiningCronServiceDataModel.fromMap);

      // Here i change the data that won't effect the
      final currentDappHooksData = state.dappHooksData;
      final newData = changeCronTransitionRequestModel.data;

      if (newData != null) {
        final minersList = newData.minersList ??
            currentDappHooksData.minerHooks.selectedMiners;
        dAppHooksUseCase.updateMinersList(minersList);

        final newTimeOfDay = TimeOfDay.fromDateTime(newData.time!);
        final currentTimeOfDay =
            TimeOfDay.fromDateTime(currentDappHooksData.minerHooks.time);

        if (newData.time != null && newTimeOfDay != currentTimeOfDay) {
          await minerHooksHelper.changeMinerHookTiming(newTimeOfDay);
        }
      }

      final miningCronServiceData =
          MiningCronServiceDataModel.fromDAppHooksData(
              dAppHooksUseCase.dappHooksData.value);

      final responseData = CronServiceDataModel.fromDAppHooksData(
          axsCronService,
          dAppHooksUseCase.dappHooksData.value,
          miningCronServiceData);

      final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
          status: AXSJSChannelResponseStatus.success,
          data: responseData,
          message: null);
      return response.toMap(miningCronServiceData.toMapWrapper);
    } else {
      throw 'Unknown service';
    }
  }

  Future<Map<String, dynamic>> handleChangeCronTransitionStatusEvent(
    Map<String, dynamic> channelData,
    AXSCronServices axsCronService,
  ) async {
    if (axsCronService == AXSCronServices.miningAutoClaimCron) {
      final status = channelData['cron']['status'];

      await minerHooksHelper.changeMinerHooksEnabled(status);
      final miningCronServiceData =
          MiningCronServiceDataModel.fromDAppHooksData(
              dAppHooksUseCase.dappHooksData.value);

      final responseData = CronServiceDataModel.fromDAppHooksData(
          axsCronService,
          dAppHooksUseCase.dappHooksData.value,
          miningCronServiceData);
      final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
          status: AXSJSChannelResponseStatus.success,
          message: null,
          data: responseData);
      return response.toMap(miningCronServiceData.toMapWrapper);
    } else {
      throw 'Unknown cron service';
    }
  }

  Future<Map<String, dynamic>> handleGetSystemInfoEvent(
    Map<String, dynamic> channelData,
    AXSCronServices axsCronService,
  ) async {
    if (axsCronService == AXSCronServices.miningAutoClaimCron) {
      final dappHooksData = state.dappHooksData;

      final miningCronServiceData =
          MiningCronServiceDataModel.fromDAppHooksData(dappHooksData);

      final responseData = CronServiceDataModel.fromDAppHooksData(
          axsCronService, dappHooksData, miningCronServiceData);
      final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
        status: AXSJSChannelResponseStatus.success,
        message: null,
        data: responseData,
      );
      return response.toMap(miningCronServiceData.toMapWrapper);
    } else {
      throw 'Unknown cron service';
    }
  }

  Future<Map<String, dynamic>> handleGoToAdvancedSettingsEvent(
      Map<String, dynamic> channelData, AXSCronServices axsCronService) async {
    goToAdvancedSettings();
    final response = AXSJSChannelResponseModel<MiningCronServiceDataModel>(
        status: AXSJSChannelResponseStatus.success, message: null, data: null);
    return response.toMap((data) => {});
  }

  void goToAdvancedSettings() {
    navigator!.push(route(
      const DAppHooksPage(),
    ));
  }
}
