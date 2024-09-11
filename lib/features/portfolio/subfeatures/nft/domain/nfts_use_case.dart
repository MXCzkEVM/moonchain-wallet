import 'package:moonchain_wallet/core/core.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'nfts_repository.dart';

class NftsUseCase extends ReactiveUseCase {
  NftsUseCase(this._repository);

  final NftsRepository _repository;

  late final ValueStream<List<Nft>> nfts = reactiveField(_repository.nfts);

  List<Nft> getNfts() => _repository.items;

  void addItem(Nft item) {
    _repository.addItem(item);
    update(nfts, _repository.items);
  }

  void removeItem(Nft item) {
    _repository.removeItem(item);
    update(nfts, _repository.items);
  }

  void removeAll() {
    _repository.removeAll();
    update(nfts, _repository.items);
  }

  void addAll(List<Nft> nftList) {
    _repository.addAll(nftList);
    update(nfts, _repository.items);
  }

  void mergeNewList(List<Nft>? newNftList) {
    if (newNftList != null && newNftList.isNotEmpty) {
      update(nfts, newNftList);

      // // updating cache by removing removed nfts
      // for (Nft nft in nfts.value) {
      //   final foundItemIndex = newNftList.indexWhere((element) =>
      //       (element.address == nft.address && element.tokenId == nft.tokenId));

      //   // If cached nft does not exists in new list
      //   if (foundItemIndex == -1) {
      //     // nfts.value.removeAt(foundItemIndex);
      //     _repository.removeItem(nft);
      //     update(nfts, _repository.items);
      //   }
      // }

      // // updating cache by adding new nfts
      // for (Nft nft in newNftList) {
      //   final foundItemIndex = nfts.value.indexWhere((element) =>
      //       (element.address == nft.address && element.tokenId == nft.tokenId));

      //   // If cached nft does not exists in new list
      //   if (foundItemIndex == -1) {
      //     // nfts.value.add(nft);
      //     _repository.addItem(nft);
      //     update(nfts, _repository.items);
      //   }
      // }
    }
  }
}
