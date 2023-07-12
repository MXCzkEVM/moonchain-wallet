import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class SendCryptoState with EquatableMixin {
  bool online = false;
  Token? token;

  @override
  List<Object?> get props => [
        token,
        online,
      ];
}
