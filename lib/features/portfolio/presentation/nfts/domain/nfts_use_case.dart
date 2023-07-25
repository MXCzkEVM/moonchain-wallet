import 'package:datadashwallet/core/core.dart';
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
}
