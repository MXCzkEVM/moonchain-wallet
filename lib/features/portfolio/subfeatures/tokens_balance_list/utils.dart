import 'package:datadashwallet/common/common.dart';
import 'package:mxc_logic/mxc_logic.dart';

import 'widgets/token_balance_item.dart';

class TokensBalanceListUtils {
  static List<TokenBalanceItem> generateTokensBalanceList(
      List<Token> tokensBalanceModel,
      {Function(Token token)? onSelected}) {
    List<TokenBalanceItem> widgets = [];

    for (int i = 0; i < tokensBalanceModel.length; i++) {
      final currentToken = tokensBalanceModel[i];

      final logoUrl = currentToken.logoUri ?? 'assets/svg/networks/unknown.svg';

      String balance = currentToken.balance?.toString() ?? '0.0';
      String balanceInXsd = currentToken.balance?.toString() ?? '0.0';
      final tokenName = currentToken.name ?? '';
      final symbol = currentToken.symbol ?? '';

      balance = tokenName == 'MXC Token'
          ? balance
          : Formatter.formatNumberForUI(balance);
      balanceInXsd = tokenName == 'MXC Token'
          ? balance
          : Formatter.formatNumberForUI(balanceInXsd);

      widgets.add(TokenBalanceItem(
        logoUrl: logoUrl,
        balance: balance,
        symbol: symbol,
        tokenName: tokenName,
        balanceInXsd: balanceInXsd,
        onTap:
            onSelected != null ? () => onSelected(tokensBalanceModel[i]) : null,
      ));
    }

    widgets.sort((a, b) => double.parse(b.balanceInXsd.replaceAll(',', ''))
        .compareTo(double.parse(a.balanceInXsd.replaceAll(',', ''))));

    return widgets;
  }
}
