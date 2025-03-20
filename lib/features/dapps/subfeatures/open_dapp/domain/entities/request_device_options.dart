import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'bluetooth_les_scan_filter.dart';
import 'guid_helper.dart';

class RequestDeviceOptions {
  final List<BluetoothLEScanFilter>? filters;
  final List<Guid>? optionalServices;
  final List<int>? optionalManufacturerData;
  final bool? acceptAllDevices;

  RequestDeviceOptions({
    this.filters,
    this.optionalServices,
    this.optionalManufacturerData,
    this.acceptAllDevices,
  });

  factory RequestDeviceOptions.fromJson(String source) =>
      RequestDeviceOptions.fromMap(json.decode(source));

  factory RequestDeviceOptions.fromMap(Map<String, dynamic> json) {
    return RequestDeviceOptions(
      filters: json['filters'] != null
      ? List<BluetoothLEScanFilter>.from(
          (json['filters'] as List<dynamic>)
              .where((filter) => filter is Map<String, dynamic> && filter.isNotEmpty) // Ensure it's a Map and not empty
              .map((filter) => BluetoothLEScanFilter.fromMap(filter as Map<String, dynamic>)))
      : null,
      optionalServices: json['optionalServices'] != null
          ? List<Guid>.from((json['optionalServices'] as List<dynamic>)
              .map((service) => GuidHelper.parse(service)))
          : null,
      optionalManufacturerData: json['optionalManufacturerData'] != null
          ? List<int>.from(json['optionalManufacturerData'])
          : null,
      acceptAllDevices: json['acceptAllDevices'],
    );
  }
}
