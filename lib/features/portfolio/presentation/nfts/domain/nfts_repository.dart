import 'package:datadashwallet/features/portfolio/presentation/nfts/entities/nft.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:datadashwallet/core/core.dart';

class NFTsRepository extends ControlledCacheRepository {
  @override
  final String zone = 'nfts';

  late final Field<List<NFT>> nfts = fieldWithDefault<List<NFT>>(
    'items',
    [],
    serializer: (t) => t
        .map((e) => {
              'address': e.address,
              'collectionID': e.collectionID,
              'image': e.image,
            })
        .toList(),
    deserializer: (t) => (t as List)
        .map((e) => NFT(
              address: e['address'],
              collectionID: e['collectionID'],
              image: e['image'],
            ))
        .toList(),
  );

  List<NFT> get items => nfts.value;

  void addItem(NFT item) => nfts.value = [...nfts.value, item];

  void removeItem(NFT item) => nfts.value = nfts.value
      .where((e) =>
          e.address != item.address && e.collectionID != item.collectionID)
      .toList();
}
