import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/features/portfolio/portfolio_page.dart';
import 'package:datadashwallet/features/portfolio/portfolio_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../common.dart';

class ManagePortfolioSection extends HookConsumerWidget {
  const ManagePortfolioSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            color: ColorsTheme.of(context).textSecondary,
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
            color: ColorsTheme.of(context).textPrimary.withOpacity(0.32),
            size: 16,
          )
        ],
      ),
    );
  }
}
