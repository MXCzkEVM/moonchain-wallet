import 'dart:async';
import 'dart:convert';
import 'package:datadashwallet/features/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/domain/chain_configuration_use_case.dart';

import '../../../../../../app/logger.dart';

class BlueberryRingBackgroundSyncUseCase extends ReactiveUseCase {
  BlueberryRingBackgroundSyncUseCase(
      this._repository,
      this._chainConfigurationUseCase,
      this._bluetoothUseCase,
      this._blueberryRingUseCase,
      this._accountUserCase,
      this._contextLessTranslationUseCase);

  final Web3Repository _repository;
  final ChainConfigurationUseCase _chainConfigurationUseCase;
  final BluetoothUseCase _bluetoothUseCase;
  final BlueberryRingUseCase _blueberryRingUseCase;
  final AccountUseCase _accountUserCase;
  final ContextLessTranslationUseCase _contextLessTranslationUseCase;


  // Context less translation, This should be only used for BG functions
  String cTranslate(String key) =>
      _contextLessTranslationUseCase.translate(key);


  Future<bool> syncRings({
    required List<String> selectedRingsListId,
    required Account account,
    required void Function(String title, String? text) showNotification,
    required String Function(
      String key,
    )
        translate,
  }) async {
                 // Get miner from cache 
        // for (String ring in selectedRings) { 
          
        // }
    // Get rings list 
        // Get the data from contract 
//         async function arrayFilterDate<T>(array: T[], date?: number) {
//   if (!date)
//     return array
//   return array.filter((item: any) => item.date > (date || 0)) as T[]
//    }
// arrayFilterDate(arr, detail.steps.at(-1)?.date)
// List<T> arrayFilterDate<T>(List<T> array, {int? date}) {
//   if (date == null) return array;
  
//   return array.where((item) {
//     var itemDate = (item as dynamic).date; // Use 'dynamic' to access the 'date' property
//     return itemDate > (date ?? 0);
//   }).toList();
// }

    // showNotification(
    //   translate('no_token_to_claim_miner')
    //       .replaceFirst('{0}', miner.mep1004TokenId!),
    //   null,
    // );
  // no_rings_owned_notification
  // syncing_data_from_ring
  // already_synced_ring
  // data_synced_successfully_ring
  // data_syncing_failed
    // final memo = await fetchRingData();

    // final postClaimRequest = PostClaimRequestModel(
    //   sncode: ring.sncode,
    //   sender: account.address,
    // );
    // final postClaimResponse = await _repository.blueberryRingRepository.postClaim(
    //   postClaimRequest,
    // );

    // final txSig = await _repository.blueberryRingRepository.sendSyncTransaction(account.privateKey, ring, postClaimResponse, memo);

    // // showNotification(
    // //   translate('no_token_to_claim_miner')
    // //       .replaceFirst('{0}', miner.mep1004TokenId!),
    // //   null,
    // // );

    return true;
  }

  Future<void> syncRing(BlueberryRingMiner ring) async{}


  Future<String> fetchRingData() async {
    collectLog('fetchRingData');
    
    final sleep = await _blueberryRingUseCase.readSleep();
    final bloodOxygens = await _blueberryRingUseCase.readBloodOxygens();
    final steps = await _blueberryRingUseCase.readSteps();
    final heartRate = await _blueberryRingUseCase.readHeartRate();

    final data = {
      'sleep': sleep.map((e) => e.toJson()).toList(),
      'steps': steps.map((e) => e.toJson()).toList(),
      'heartRate': heartRate.map((e) => e.toJson()).toList(),
      'bloodOxygens': bloodOxygens.map((e) => e.toJson()).toList(),
    };


    final content = json.encode(data);

    collectLog('fetchRingData:content : $content');

    final mep3355 = {
      'format': 'MEP-3355',
      'version': '1.0.0',
      'metadata': {
        'data_source': 'BlueberryRingV1',
        'data_collection_method': 'bluetooth',
        'preprocessing': 'weighted average of data',
      },
      'data': [
        {
          'type': 'sensor',
          // 'content': await compress(content),
          'compression': 'brotli',
        },
      ],
    };

    collectLog('fetchRingData:content : $mep3355');

    final returndataMap = {
      'json': mep3355,
      'data': data,
    };
    final returnDataJson = json.encode(returndataMap);
    return returnDataJson;
  }

}
