import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AddNftState with EquatableMixin {
  bool valid = false;
  Account? account;

  @override
  List<Object?> get props => [valid, account];
}
