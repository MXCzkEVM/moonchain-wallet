import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AppNavBarState with EquatableMixin {
  Account? account;

  @override
  List<Object?> get props => [
        account,
      ];
}
