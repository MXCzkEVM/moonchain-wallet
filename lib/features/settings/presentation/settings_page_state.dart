import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class SettingsState with EquatableMixin {
  Account? account;
  List<Account> accounts = [];
  String? appVersion;

  @override
  List<Object?> get props => [
        account,
        accounts,
        appVersion,
      ];
}
