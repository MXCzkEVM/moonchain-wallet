import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

import 'entities/network.dart';

class ChainConfigurationState with EquatableMixin {
  List<Network> networks = [];

  @override
  List<Object?> get props => [
        networks,
      ];
}
