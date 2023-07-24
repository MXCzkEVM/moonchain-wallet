import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/portfolio_page_presenter.dart';
import 'package:datadashwallet/features/portfolio/presentation/nfts/nft_list/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../add_nft/add_nft_page.dart';

class NFTList extends HookConsumerWidget {
  const NFTList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioContainer.state);

    String translate(String text) => FlutterI18n.translate(context, text);

    return Column(
      children: [
        portfolioState.nftCollectionList != null &&
                portfolioState.nftCollectionList!.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  translate('no_nfts_added_yet'),
                  style: FontTheme.of(context).h6().copyWith(
                        fontSize: 18,
                      ),
                ),
              )
            : portfolioState.nftCollectionList == null
                ? const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()))
                : Column(
                    children: NFTListUtils.generateNFTList(
                        portfolioState.nftCollectionList!),
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
                  const AddNFTPage(),
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
