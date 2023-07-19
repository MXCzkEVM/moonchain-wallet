import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/presentation/nfts/entities/nft.dart';

import 'nfts_repository.dart';

class NFTsUseCase extends ReactiveUseCase {
  NFTsUseCase(this._repository);

  final NFTsRepository _repository;

  late final ValueStream<List<NFT>> nfts =
      reactiveField(_repository.nfts);

  List<NFT> getTokens() => _repository.items;

  void addItem(NFT item) {
    _repository.addItem(item);
    update(nfts, _repository.items);
  }

  void removeItem(NFT item) {
    _repository.removeItem(item);
    update(nfts, _repository.items);
  }
}
