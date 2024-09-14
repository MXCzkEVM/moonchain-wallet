import 'package:moonchain_wallet/features/wallet/wallet.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class BalanceChart extends HookConsumerWidget {
  const BalanceChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletContainer.state);

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
                height: 55,
                width: 130,
                child: LineChart(LineChartData(
                  gridData: FlGridData(
                    show: false,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  minX: 0,
                  minY: 0,
                  maxX: 6,
                  maxY: state.chartMaxAmount,
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.transparent)),
                  lineBarsData: [
                    LineChartBarData(
                        spots: state.balanceSpots,
                        isCurved: true,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: false,
                        ),
                        color: ColorsTheme.of(context).borderPrimary200,
                        belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(colors: [
                              ColorsTheme.of(context)
                                  .primary400
                                  .withOpacity(0.25),
                              ColorsTheme.of(context)
                                  .primary400
                                  .withOpacity(0.0)
                            ], stops: const [
                              0,
                              0.6,
                            ], transform: const GradientRotation(1.5708))))
                  ],
                ))),
            SizedBox(
              height: 55,
              child: DottedLine(
                direction: Axis.vertical,
                dashLength: 3,
                dashGapLength: 3,
                dashColor: ColorsTheme.of(context).borderPrimary100,
              ),
            )
          ],
        ),
        Text(
          FlutterI18n.translate(context, '7_days'),
          style: FontTheme.of(context).caption1().copyWith(
                color: ColorsTheme.of(context).textSecondary,
              ),
        )
      ],
    );
  }
}
