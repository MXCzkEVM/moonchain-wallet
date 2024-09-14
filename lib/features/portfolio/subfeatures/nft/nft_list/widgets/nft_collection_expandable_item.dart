import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/nft_list/widgets/nft_item.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

class NFTCollectionExpandableItem extends StatefulWidget {
  const NFTCollectionExpandableItem({
    super.key,
    required this.collection,
    this.onSelected,
  });

  final List<Nft> collection;
  final Function(Nft token)? onSelected;

  @override
  State<NFTCollectionExpandableItem> createState() => _NFTCollectionState();
}

class _NFTCollectionState extends State<NFTCollectionExpandableItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              widget.collection[0].name,
              style: FontTheme.of(context).body2.primary(),
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              '(${widget.collection.length})',
              style: FontTheme.of(context).body2.secondary(),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        collapsedTextColor: Colors.transparent,
        collapsedIconColor: ColorsTheme.of(context).textPrimary,
        iconColor: ColorsTheme.of(context).textPrimary,
        childrenPadding: EdgeInsets.zero,
        trailing: Icon(
          isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: 24,
          color: ColorsTheme.of(context).iconPrimary,
        ),
        onExpansionChanged: (expansion) {
          setState(() {});
          isExpanded = expansion;
        },
        tilePadding: EdgeInsets.zero,
        children: [
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 10.0,
            shrinkWrap: true,
            children: widget.collection
                .map(
                  (e) => InkWell(
                    onTap: widget.onSelected != null
                        ? () => widget.onSelected!(e)
                        : null,
                    child: NFTItem(imageUrl: e.image),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
