import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluePlusBluetoothUtils {
// Return blue plus bluetooth device
  static BluetoothService? getPrimaryService(
      List<BluetoothService> services, Guid targetServiceUUID) {
    BluetoothService? primaryService;
    for (BluetoothService service in services) {
      if (service.uuid == targetServiceUUID && service.isPrimary) {
        primaryService = service;
      }
    }
    return primaryService;
  }

  static  BluetoothCharacteristic? getCharacteristic(
      List<BluetoothCharacteristic> characteristics,
      Guid targetCharacteristicUUID) {
    BluetoothCharacteristic? targetCharacteristic;
    for (BluetoothCharacteristic characteristic in characteristics) {
      if (characteristic.characteristicUuid == targetCharacteristicUUID) {
        targetCharacteristic = characteristic;
      }
    }
    return targetCharacteristic;
  }
}
