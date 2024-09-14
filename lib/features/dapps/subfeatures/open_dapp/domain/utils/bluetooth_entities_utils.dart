import 'package:moonchain_wallet/features/common/packages/bluetooth/blue_plus/blue_plus.dart';

import '../../open_dapp.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;

class BluetoothEntitiesUtils {
  static BluetoothRemoteGATTCharacteristic getBluetoothRemoteGATTCharacteristic(
      blue_plus.BluetoothCharacteristic selectedCharacteristic,
      blue_plus.BluetoothService selectedService,
      blue_plus.ScanResult selectedScanResult) {
    final device =
        BluetoothDevice.getBluetoothDeviceFromScanResult(selectedScanResult);
    final bluetoothRemoteGATTService =
        BluetoothRemoteGATTService.fromBluetoothService(
            device, selectedService);
    final bluetoothRemoteGATTCharacteristic = BluetoothRemoteGATTCharacteristic(
        service: bluetoothRemoteGATTService,
        properties:
            BluetoothCharacteristicProperties.fromCharacteristicProperties(
                selectedCharacteristic.properties),
        uuid: selectedCharacteristic.uuid.str,
        value: null);
    return bluetoothRemoteGATTCharacteristic;
  }

  static blue_plus.BluetoothCharacteristic getSelectedCharacteristic(
      String uuid, blue_plus.BluetoothService selectedService) {
    final characteristicUUID = GuidHelper.parse(uuid);
    final selectedCharacteristic =
        BluePlusBluetoothUtils.getCharacteristicWithService(
            selectedService, characteristicUUID);
    return selectedCharacteristic;
  }

  static Future<blue_plus.BluetoothService> getSelectedService(
      String uuid, blue_plus.ScanResult selectedScanResult) async {
    final serviceUUID = GuidHelper.parse(uuid);
    final selectedService = await BluePlusBluetoothUtils.getPrimaryService(
        selectedScanResult, serviceUUID);
    return selectedService;
  }
}
