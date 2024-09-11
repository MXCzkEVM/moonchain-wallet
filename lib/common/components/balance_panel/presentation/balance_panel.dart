import 'package:moonchain_wallet/common/components/balance_panel/widgets/balance_chart.dart';
import 'package:moonchain_wallet/common/components/balance_panel/widgets/balance_in_xsd.dart';
import 'package:moonchain_wallet/common/components/balance_panel/widgets/balance_title.dart';
import 'package:moonchain_wallet/common/components/balance_panel/widgets/manage_portfolio_section.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

export '../domain/balance_repository.dart';
export '../domain/balance_use_case.dart';

import '../../../../../common/common.dart';
import '../widgets/change_indicator.dart';

class BalancePanel extends HookConsumerWidget {
  final bool showGraph;
  const BalancePanel(this.showGraph, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GreyContainer(
        padding: const EdgeInsetsDirectional.all(16),
        child: showGraph
            ? _showWithGraph(
                context,
              )
            : _showSimple(context));
  }

  Widget _showWithGraph(
    BuildContext context,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            BalanceTitle(),
            SizedBox(
              height: 4,
            ),
            BalanceInXSD(),
            ChangeIndicator()
          ],
        ),
        const Spacer(),
        const BalanceChart()
      ],
    );
  }

  Widget _showSimple(
    BuildContext context,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [BalanceTitle(), Spacer(), BalanceInXSD()],
        ),
        const ChangeIndicator(),
        const SizedBox(
          height: 12,
        ),
        Divider(
          color: ColorsTheme.of(context).primaryBackground,
          height: 24,
          thickness: 0.5,
        ),
        const ManagePortfolioSection()
      ],
    );
  }
}
