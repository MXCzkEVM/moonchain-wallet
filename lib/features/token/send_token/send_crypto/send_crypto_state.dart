import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class SendCryptoState with EquatableMixin {
  bool online = false;
  Token? token;
  int discount = 0;

  @override
  List<Object?> get props => [
        token,
        online,
        discount,
      ];
}
