import 'package:datadashwallet/common/components/recent_transactions/widgets/recent_transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../../common/common.dart';
import 'tokens_balance_list.dart';
import 'widgets/token_balance_item.dart';

class TokensBalanceListUtils {
  static List<TokenBalanceItem> generateTokensBalanceList(
      WannseeTokensBalanceModel tokensBalanceModel,
      DefaultTokens defaultTokensList,
      String mxcBalance) {
    List<TokenBalanceItem> widgets = [];

    for (int i = 0; i < defaultTokensList.tokens!.length; i++) {
      final currentToken = defaultTokensList.tokens![i];

      String logoUrl = currentToken.logoUri!;

      // final currentToken = tokensBalanceModel.items![i];
      String balance = '0';
      String balanceInXsd = '0';
      String tokenName = currentToken.name!;
      String symbol = currentToken.symbol!;

      if (tokensBalanceModel.items != null) {
        final tokenIndex = tokensBalanceModel.items!.indexWhere(
          (element) => element.token!.address == currentToken.address,
        );
        if (tokenIndex != -1) {
          final selectedToken = tokensBalanceModel.items![tokenIndex];
          balance = Formatter.formatNumberForUI(selectedToken.value!);
          balanceInXsd = Formatter.formatNumberForUI(selectedToken.value!);
        }
      }

      widgets.add(TokenBalanceItem(
        logoUrl: logoUrl,
        balance: balance,
        symbol: symbol,
        tokenName: tokenName,
        balanceInXsd: balanceInXsd,
      ));
    }

    widgets.add(TokenBalanceItem(
        logoUrl:
            'https://raw.githubusercontent.com/MXCzkEVM/wannseeswap-tokenlist/main/assets/mxc.svg',
        balance: mxcBalance,
        symbol: 'MXC',
        balanceInXsd: mxcBalance,
        tokenName: 'MXC Token'));

    widgets.sort((a, b) =>
        double.parse(b.balanceInXsd).compareTo(double.parse(a.balanceInXsd)));

    return widgets;
  }
}
