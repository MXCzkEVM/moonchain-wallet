import 'package:equatable/equatable.dart';

class CustomerSupportState with EquatableMixin {
  String exportedLogsPath = '';
  bool notImportantLogsEnabled = false;
  Map applist = {};

  @override
  List<Object?> get props => [
        exportedLogsPath,
        applist,
        notImportantLogsEnabled,
      ];
}
