import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluePlusBluetoothUtils {
  static Future<BluetoothService> getPrimaryService(
    ScanResult selectedScanResult,
    Guid serviceUUID,
  ) async {
    final services = await selectedScanResult.device.discoverServices();
    final service = _getPrimaryServiceWithUUID(services, serviceUUID);
    if (service != null) {
      return service;
    } else {
      throw "Service with ${serviceUUID.str} UUID not found";
    }
  }

  static BluetoothCharacteristic getCharacteristicWithService(
    BluetoothService service,
    Guid characteristicUUID,
  ) {
    final characteristics = service.characteristics;
    final characteristic =
        _getCharacteristicWithUUID(characteristics, characteristicUUID);
    if (characteristic != null) {
      return characteristic;
    } else {
      throw "Characteristic with ${characteristicUUID.str} UUID not found";
    }
  }

  static Future<BluetoothCharacteristic> getCharacteristicWithServiceUUID(
    ScanResult selectedScanResult,
    Guid serviceUUID,
    Guid characteristicUUID,
  ) async {
    final service = await getPrimaryService(selectedScanResult, serviceUUID);
    final characteristics = service.characteristics;
    final characteristic =
        _getCharacteristicWithUUID(characteristics, characteristicUUID);
    if (characteristic != null) {
      return characteristic;
    } else {
      throw "Characteristic with ${characteristicUUID.str} UUID not found";
    }
  }

// Return blue plus bluetooth device
  static BluetoothService? _getPrimaryServiceWithUUID(
      List<BluetoothService> services, Guid targetServiceUUID) {
    BluetoothService? primaryService;
    for (BluetoothService service in services) {
      if (service.uuid == targetServiceUUID && service.isPrimary) {
        primaryService = service;
      }
    }
    return primaryService;
  }

  static BluetoothCharacteristic? _getCharacteristicWithUUID(
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
