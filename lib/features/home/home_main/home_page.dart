import 'package:datadashwallet/features/home/home_main/presentation/widgets/balance_panel.dart';
import 'package:datadashwallet/features/home/home_main/presentation/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/common/common.dart';

String formatBigNumber(double number) {
  if (number >= 1000000000) {
    // Convert to millions
    double num = number / 1000000000.0;
    return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}B';
  } else if (number >= 1000000) {
    // Convert to millions
    double num = number / 1000000.0;
    return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}M';
  } else if (number >= 1000) {
    // Convert to thousands
    double num = number / 1000.0;
    return '${num.toStringAsFixed(num.truncateToDouble() == num ? 0 : 1)}K';
  } else {
    int accuracy = number.toString().split('.').last.length;
    var str = number.toString();
    if (str.endsWith('.0')) {
      return str.substring(0, str.length - 2);
    }
    return number.toStringAsFixed(accuracy);
  }
}

String formatWalletAddress(String inputString) {
  String formattedString = '${inputString.substring(0, 6)}...${inputString.substring(inputString.length - 4)}';
  return formattedString;
}

class HomePage extends HomeBasePage with HomeScreenMixin {
  const HomePage({Key? key}) : super(key: key);

  @override
  ProviderBase<HomePagePresenter> get presenter => HomePageContainer.actions;

  @override
  ProviderBase<HomePageState> get state => HomePageContainer.state;

  @override
  int get bottomNavCurrentIndex => 0;

  @override
  List<Widget> setContent(BuildContext context, WidgetRef ref) {
    return const [
      Expanded(flex: 2, child: BalancePanel()),
      SizedBox(
        height: 10,
      ),
      Expanded(flex: 3, child: RecentTransactions()),
      SizedBox(
        height: 10,
      ),
      Expanded(flex: 3, child: HomeSlider()),
    ];
  }
}
