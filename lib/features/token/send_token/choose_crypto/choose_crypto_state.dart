import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class ChooseCryptoState with EquatableMixin {
  List<Token>? tokens;
  List<Token>? fliterTokens;
  String walletAddress = '';

  @override
  List<Object?> get props => [
        tokens,
        fliterTokens,
        walletAddress,
      ];
}
