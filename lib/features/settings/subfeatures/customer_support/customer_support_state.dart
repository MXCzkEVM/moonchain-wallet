import 'package:equatable/equatable.dart';

class CustomerSupportState with EquatableMixin {
  String exportedLogsPath = '';
  Map applist = {};

  @override
  List<Object?> get props => [
        exportedLogsPath,
        applist,
      ];
}
