import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class GuidHelper {
  static Guid parse(dynamic data) {
    if (data is String) {
      return Guid.fromString(data);
    } else if (data is List<int>) {
      return Guid.fromBytes(data);
    } else {
      throw 'Unable to parse Guid';
    }
  }
}
