import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/dapps/dapps.dart';
import 'package:moonchain_wallet/features/portfolio/portfolio.dart';
import 'package:mxc_ui/mxc_ui.dart';

class BuyNFTButton extends StatelessWidget {
  const BuyNFTButton({super.key, required this.presenter});

  final PortfolioPresenter presenter;

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? MxcChipButton(
            key: const Key('buyNFT'),
            title: FlutterI18n.translate(context, 'buy_x')
                .replaceFirst('{0}', 'NFT'),
            iconData: Icons.add_rounded,
            alignIconStart: true,
            onTap: () {
              final launchUrl = presenter.getNftMarketPlaceUrl();
              if (launchUrl != null) {
                Navigator.of(context).push(route.featureDialog(
                  maintainState: false,
                  OpenDAppPage(
                    url: launchUrl,
                  ),
                ));
              }
            },
            backgroundColor: ColorsTheme.of(context).darkGray,
          )
        : Container();
  }
}
