import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/chain_configuration/entities/network.dart';
import './network_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

class NetworkItem extends StatelessWidget {
  const NetworkItem({super.key, required this.network, required this.onTap});

  final Network network;
  final void Function(Network network) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          route.featureDialog(
            NetworkDetailsPage(network: network),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.spaceNormal),
        child: Row(children: [
          SvgPicture.asset(
            network.logo,
            height: 24,
            width: 24,
          ),
          const SizedBox(
            width: Sizes.spaceXLarge,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                network.label,
                style: FontTheme.of(context).body2.primary(),
              ),
              network.enabled
                  ? Text(
                      FlutterI18n.translate(context, 'default'),
                      style: FontTheme.of(context).body1().copyWith(
                          color: ColorsTheme.of(context).textWhite100),
                    )
                  : Container(),
            ],
          ),
          const Spacer(),
          if (onTap != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Sizes.spaceNormal),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ColorsTheme.of(context).white400,
              ),
            ),
        ]),
      ),
    );
  }
}
