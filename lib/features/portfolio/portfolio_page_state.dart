import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class PortfolioState with EquatableMixin {
  String walletBalance = "0.0";

  List<Token>? tokensList;

  List<NFTCollection>? nftCollectionList;

  String? walletAddress;

  bool switchTokensOrNFTs = true;

  bool isWalletAddressCopied = false;



  @override
  List<Object?> get props => [
        walletBalance,
        tokensList,
        walletAddress,
        switchTokensOrNFTs,
        isWalletAddressCopied,
        nftCollectionList
      ];
}
