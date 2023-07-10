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
                  maxY: 891,
                  borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.transparent)),
                  lineBarsData: [
                    LineChartBarData(
                        spots: const [
                          FlSpot(0, 891),
                          FlSpot(1, 100),
                          FlSpot(2, 520),
                          FlSpot(3, 400),
                          FlSpot(4, 530),
                          FlSpot(5, 500),
                          FlSpot(6, 800)
                        ],
                        isCurved: true,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: false,
                        ),
                        color: ColorsTheme.of(context).purpleMain,
                        belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(colors: [
                              ColorsTheme.of(context)
                                  .purpleMain
                                  .withOpacity(0.8),
                              ColorsTheme.of(context)
                                  .purpleMain
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
                dashColor: ColorsTheme.of(context).purpleMain,
              ),
            )
          ],
        ),
        Text(
          FlutterI18n.translate(context, '7_days'),
          style: FontTheme.of(context).h7().copyWith(
              fontSize: 10,
              color: ColorsTheme.of(context).purpleMain,
              fontWeight: FontWeight.w400),
        )
      ],
    );
  }
}
