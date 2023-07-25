import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/nfts/nft_list/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../add_nft/add_nft_page.dart';

class NFTList extends HookConsumerWidget {
  const NFTList({
    super.key,
    required this.nfts,
    this.onSelected,
  });

  final List<Nft> nfts;
  final Function(Nft token)? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return Column(
      children: [
        nfts.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  translate('no_nfts_added_yet'),
                  style: FontTheme.of(context).h6().copyWith(
                        fontSize: 18,
                      ),
                ),
              )
            : Column(
                children: NFTListUtils.generateNFTList(
                  nfts,
                  onSelected: onSelected,
                ),
              ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MxcChipButton(
              key: const Key('addNFTButton'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onTap: () => Navigator.of(context).push(
                route.featureDialog(
                  const AddNftPage(),
                ),
              ),
              title: translate('add_x').replaceFirst('{0}', 'NFT'),
              iconData: Icons.add,
              alignIconStart: true,
            ),
          ],
        ),
      ],
    );
  }
}
