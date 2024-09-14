import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/nft_list/widgets/nft_collection_expandable_item.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:collection/collection.dart';

class NFTListUtils {
  static List<NFTCollectionExpandableItem> generateNFTList(
    List<Nft> nftList, {
    Function(Nft token)? onSelected,
  }) {
    List<NFTCollectionExpandableItem> widgets = [];
    final groupedLists = groupBy(nftList, (nft) => nft.address);
    final keys = groupedLists.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      widgets.add(NFTCollectionExpandableItem(
        collection: groupedLists[keys[i]] ?? [],
        onSelected: onSelected,
      ));
    }

    return widgets;
  }
}
