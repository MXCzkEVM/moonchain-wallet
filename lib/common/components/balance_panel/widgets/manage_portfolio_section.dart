import 'package:moonchain_wallet/core/core.dart';
import 'package:moonchain_wallet/features/portfolio/presentation/portfolio_page.dart';
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
    return InkWell(
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
            MxcIcons.coins,
            color: ColorsTheme.of(context).iconSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            FlutterI18n.translate(context, 'send_&_receive'),
            style: FontTheme.of(context)
                .body1()
                .copyWith(color: ColorsTheme.of(context).textPrimary),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: ColorsTheme.of(context).iconGrey3,
            size: 20,
          )
        ],
      ),
    );
  }
}
