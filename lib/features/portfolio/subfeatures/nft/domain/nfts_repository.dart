import 'package:mxc_logic/mxc_logic.dart';
import 'package:moonchain_wallet/core/core.dart';

class NftsRepository extends ControlledCacheRepository {
  @override
  final String zone = 'nfts';

  late final Field<List<Nft>> nfts = fieldWithDefault<List<Nft>>(
    'items',
    [],
    serializer: (t) => t
        .map((e) => {
              'address': e.address,
              'tokenId': e.tokenId,
              'image': e.image,
              'name': e.name,
            })
        .toList(),
    deserializer: (t) => (t as List)
        .map((e) => Nft(
              address: e['address'],
              tokenId: e['tokenId'],
              image: e['image'],
              name: e['name'],
            ))
        .toList(),
  );

  List<Nft> get items => nfts.value;

  void addItem(Nft item) {
    final foundItemIndex = nfts.value.indexWhere((element) =>
        (element.address == item.address && element.tokenId == item.tokenId));

    if (foundItemIndex == -1) {
      nfts.value = [...nfts.value, item];
    }
  }

  void removeItem(Nft item) => nfts.value = nfts.value
      .where((e) => e.address != item.address && e.tokenId != item.tokenId)
      .toList();

  void removeAll() => nfts.value = [];

  void addAll(List<Nft> nftList) => nfts.value = nftList;
}
