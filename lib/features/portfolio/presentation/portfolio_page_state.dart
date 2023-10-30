import 'package:equatable/equatable.dart';
import 'package:mxc_logic/mxc_logic.dart';

class PortfolioState with EquatableMixin {
  String walletBalance = "0.0";

  List<Token>? tokensList;

  List<Nft> nftList = [];

  String? walletAddress;

  Network? network;

  bool switchTokensOrNFTs = true;

  String? ipfsGateway;

  bool buyEnabled = true;

  @override
  List<Object?> get props =>
      [walletBalance, tokensList, walletAddress, switchTokensOrNFTs, nftList];
}
