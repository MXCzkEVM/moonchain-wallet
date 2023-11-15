import 'dart:io';

import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/dapps/dapps.dart';
import 'package:datadashwallet/features/portfolio/presentation/portfolio_page_presenter.dart';
import 'package:datadashwallet/features/portfolio/subfeatures/nft/nft_list/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

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
        if (Platform.isAndroid)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MxcChipButton(
                key: const Key('buyNFTButton'),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onTap: () {
                  final launchUrl = presenter.getNftMarketPlaceUrl();
                  if (launchUrl != null) {
                    Navigator.of(context).push(route.featureDialog(
                      maintainState: false,
                      OpenAppPage(
                        url: launchUrl,
                      ),
                    ));
                  }
                },
                title: translate('buy_x').replaceFirst('{0}', 'NFT'),
                iconData: Icons.add,
                alignIconStart: true,
                buttonState: state.buyEnabled
                    ? ChipButtonStates.defaultState
                    : ChipButtonStates.disabled,
              ),
            ],
          ),
      ],
    );
  }
}
