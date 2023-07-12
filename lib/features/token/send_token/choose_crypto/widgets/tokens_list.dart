import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/portfolio/presentation/tokens_balance_list/widgets/token_balance_item.dart';
import 'package:flutter/widgets.dart';

class TokensList extends StatelessWidget {
  const TokensList({super.key});

  @override
  Widget build(BuildContext context) {
    return GreyContainer(
      child: Column(
        children: [
          TokenBalanceItem(
            logoUrl: '',
            balance: '10',
            balanceInXsd: '11',
            tokenName: 'MXC',
            symbol: 'MXC',
            onTap: () {},
          )
        ],
      ),
    );
  }
}
