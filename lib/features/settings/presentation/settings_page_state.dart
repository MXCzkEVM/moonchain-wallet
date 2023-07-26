import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mxc_logic/mxc_logic.dart';

class SettingsState with EquatableMixin {
  String? walletAddress;

  String? accountName;

  String? name;

  String? appVersion;

  @override
  List<Object?> get props => [walletAddress, accountName, name, appVersion];
}
