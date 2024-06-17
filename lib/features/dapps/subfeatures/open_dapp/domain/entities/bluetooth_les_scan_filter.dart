import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'guid_helper.dart';

class BluetoothLEScanFilter {
  final String? name;
  final String? namePrefix;
  final List<Guid>? services;
  final List<BluetoothManufacturerDataFilter>? manufacturerData;
  final List<BluetoothServiceDataFilter>? serviceData;

  BluetoothLEScanFilter({
    this.name,
    this.namePrefix,
    this.services,
    this.manufacturerData,
    this.serviceData,
  });

  factory BluetoothLEScanFilter.fromJson(String source) =>
      BluetoothLEScanFilter.fromMap(json.decode(source));

  factory BluetoothLEScanFilter.fromMap(Map<String, dynamic> json) {
    return BluetoothLEScanFilter(
      name: json['name'],
      namePrefix: json['namePrefix'],
      services: json['services'] != null
          ? List<Guid>.from(
              json['services'].map((service) => GuidHelper.parse(service)))
          : null,
      manufacturerData: json['manufacturerData'] != null
          ? List<BluetoothManufacturerDataFilter>.from(json['manufacturerData']
              .map((data) => BluetoothManufacturerDataFilter.fromMap(data)))
          : null,
      serviceData: json['serviceData'] != null
          ? List<BluetoothServiceDataFilter>.from(json['serviceData']
              .map((data) => BluetoothServiceDataFilter.fromMap(data)))
          : null,
    );
  }
}

class BluetoothDataFilter {
  final List<int>? dataPrefix;
  final List<int>? mask;

  BluetoothDataFilter({this.dataPrefix, this.mask});

  factory BluetoothDataFilter.fromJson(Map<String, dynamic> json) {
    return BluetoothDataFilter(
      dataPrefix: json['dataPrefix'] != null
          ? List<int>.from(json['dataPrefix'])
          : null,
      mask: json['mask'] != null ? List<int>.from(json['mask']) : null,
    );
  }
}

class BluetoothManufacturerDataFilter extends BluetoothDataFilter {
  final int companyIdentifier;

  BluetoothManufacturerDataFilter(
      {required this.companyIdentifier, List<int>? dataPrefix, List<int>? mask})
      : super(dataPrefix: dataPrefix, mask: mask);

  factory BluetoothManufacturerDataFilter.fromJson(String source) =>
      BluetoothManufacturerDataFilter.fromMap(json.decode(source));

  factory BluetoothManufacturerDataFilter.fromMap(Map<String, dynamic> json) {
    return BluetoothManufacturerDataFilter(
      companyIdentifier: json['companyIdentifier'],
      dataPrefix: json['dataPrefix'] != null
          ? List<int>.from(json['dataPrefix'])
          : null,
      mask: json['mask'] != null ? List<int>.from(json['mask']) : null,
    );
  }
}

class BluetoothServiceDataFilter extends BluetoothDataFilter {
  final Guid service;

  BluetoothServiceDataFilter(
      {required this.service, List<int>? dataPrefix, List<int>? mask})
      : super(dataPrefix: dataPrefix, mask: mask);

  factory BluetoothServiceDataFilter.fromJson(String source) =>
      BluetoothServiceDataFilter.fromMap(json.decode(source));

  factory BluetoothServiceDataFilter.fromMap(Map<String, dynamic> json) {
    return BluetoothServiceDataFilter(
      service: GuidHelper.parse(json['service']),
      dataPrefix: json['dataPrefix'] != null
          ? List<int>.from(json['dataPrefix'])
          : null,
      mask: json['mask'] != null ? List<int>.from(json['mask']) : null,
    );
  }
}
