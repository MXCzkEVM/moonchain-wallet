import 'package:moonchain_wallet/common/common.dart';
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

      String balance = currentToken.balance!.toString();
      String balanceInXsd = currentToken.balancePrice!.toString();
      final tokenName = currentToken.name ?? '';
      final symbol = currentToken.symbol ?? '';

      balance = MXCFormatter.formatNumberForUI(balance);
      balanceInXsd = MXCFormatter.formatNumberForUI(balanceInXsd);

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
