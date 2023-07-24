import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class ChooseNftState with EquatableMixin {
  List<Nft>? nfts;
  List<Nft>? filterNfts;
  String walletAddress = '';

  @override
  List<Object?> get props => [
        nfts,
        filterNfts,
        walletAddress,
      ];
}
