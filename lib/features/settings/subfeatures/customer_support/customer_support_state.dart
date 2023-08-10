import 'package:equatable/equatable.dart';

class CustomerSupportState with EquatableMixin {
  String exportedLogsPath = '';

  @override
  List<Object?> get props => [
        exportedLogsPath,
      ];
}
