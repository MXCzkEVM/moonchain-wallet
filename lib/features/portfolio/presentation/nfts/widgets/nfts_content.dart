import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../add_nft/add_nft_page.dart';

class NFTsContent extends StatelessWidget {
  const NFTsContent({super.key});

  @override
  Widget build(BuildContext context) {
    String translate(String text) => FlutterI18n.translate(context, text);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Text(
            translate('no_nfts_added_yet'),
            style: FontTheme.of(context).h6().copyWith(
                  fontSize: 18,
                ),
          ),
        ),
        const SizedBox(height: 4),
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
