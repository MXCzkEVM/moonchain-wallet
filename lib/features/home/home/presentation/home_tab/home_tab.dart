import 'package:flutter/material.dart';
import 'package:datadashwallet/features/home/home/presentation/widgets/balance_panel.dart';
import 'package:datadashwallet/features/home/home/presentation/widgets/slider.dart';
import 'package:datadashwallet/common/common.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      children: const [
        Expanded(flex: 2, child: BalancePanel()),
        SizedBox(
          height: 10,
        ),
        Expanded(flex: 3, child: RecentTransactions()),
        SizedBox(
          height: 10,
        ),
        Expanded(flex: 3, child: HomeSlider()),
      ],
    ));
  }
}
