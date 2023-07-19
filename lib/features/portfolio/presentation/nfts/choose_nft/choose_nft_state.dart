import 'package:equatable/equatable.dart';

import '../entities/nft.dart';

class ChooseNFTState with EquatableMixin {
  List<NFT>? nfts;
  List<NFT>? filterNFTs;
  String walletAddress = '';

  @override
  List<Object?> get props => [
        nfts,
        filterNFTs,
        walletAddress,
      ];
}
