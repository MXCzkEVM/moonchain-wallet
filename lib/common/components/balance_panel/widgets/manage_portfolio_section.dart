import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/portfolio/portfolio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../common.dart';

class ManagePortfolioSection extends StatelessWidget {
  const ManagePortfolioSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          route(
            const PortfolioPage(),
          ),
        );
      },
      child: Row(
        children: [
          Icon(
            MXCIcons.coin,
            color: ColorsTheme.of(context).secondaryText,
          ),
          Text(
            '  ${FlutterI18n.translate(context, 'manage_portfolio')}',
            style: FontTheme.of(context)
                .h7()
                .copyWith(fontWeight: FontWeight.w400, fontSize: 14),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: ColorsTheme.of(context).primaryText.withOpacity(0.32),
            size: 16,
          )
        ],
      ),
    );
  }
}
