import 'package:datadashwallet/common/components/balance_panel/widgets/balance_chart.dart';
import 'package:datadashwallet/common/components/balance_panel/widgets/balance_in_xsd.dart';
import 'package:datadashwallet/common/components/balance_panel/widgets/balance_title.dart';
import 'package:datadashwallet/common/components/balance_panel/widgets/manage_portfolio_section.dart';
import 'package:datadashwallet/core/src/routing/route.dart';
import 'package:datadashwallet/features/home/home/home_page_presenter.dart';
import 'package:datadashwallet/features/portfolio/portfolio_page.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../../../common/common.dart';
import 'widgets/change_indicator.dart';

class BalancePanel extends HookConsumerWidget {
  final bool showGraph;
  const BalancePanel(this.showGraph, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeContainer.state);
    bool showChangeIndicator = state.walletBalance != '0.0';
    return GreyContainer(
        padding: const EdgeInsets.all(16),
        child: showGraph
            ? _showWithGraph(
                context,
              )
            : _showSimple(context, showChangeIndicator));
  }

  Widget _showWithGraph(
    BuildContext context,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            BalanceTitle(fontSize: 18),
            SizedBox(
              height: 4,
            ),
            BalanceInXSD(fontSize: 18),
            ChangeIndicator()
          ],
        ),
        const Spacer(),
        const BalanceChart()
      ],
    );
  }

  Widget _showSimple(BuildContext context, bool showChangeIndicator) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [BalanceTitle(), Spacer(), BalanceInXSD()],
        ),
        showChangeIndicator ? const ChangeIndicator() : Container(),
        const SizedBox(
          height: 12,
        ),
        Divider(
          color: ColorsTheme.of(context).primaryBackground,
        ),
        const ManagePortfolioSection()
      ],
    );
  }
}
