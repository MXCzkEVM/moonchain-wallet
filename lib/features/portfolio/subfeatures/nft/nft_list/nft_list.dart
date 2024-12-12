
import 'package:moonchain_wallet/features/portfolio/presentation/portfolio_page_presenter.dart';
import 'package:moonchain_wallet/features/portfolio/subfeatures/nft/nft_list/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'widgets/buy_nft_button.dart';

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
    final presenter = ref.read(portfolioContainer.actions);
    final state = ref.read(portfolioContainer.state);
    String translate(String text) => FlutterI18n.translate(context, text);
    return Column(
      children: [
        nfts.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Text(
                      translate('no_nfts_added_yet'),
                      style: FontTheme.of(context).body2.secondary(),
                    ),
                    const SizedBox(
                      height: Sizes.spaceNormal,
                    ),
                  ],
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
            BuyNFTButton(
              presenter: presenter,
            )
          ],
        ),
      ],
    );
  }
}
