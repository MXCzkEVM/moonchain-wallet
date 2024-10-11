import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AppNavBarState with EquatableMixin {
  Account? account;
  List<Account> accounts = [];
  bool isLoading = false;

  @override
  List<Object?> get props => [
        account,
        accounts,
        isLoading,
      ];
}
