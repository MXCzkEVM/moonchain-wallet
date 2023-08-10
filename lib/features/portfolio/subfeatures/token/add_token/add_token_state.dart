import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class AddTokenState with EquatableMixin {
  Token? token;

  @override
  List<Object?> get props => [
        token,
      ];
}
