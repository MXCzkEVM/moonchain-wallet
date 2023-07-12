import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

class TokenBalanceItem extends HookConsumerWidget {
  const TokenBalanceItem({
    Key? key,
    required this.logoUrl,
    required this.balance,
    required this.symbol,
    required this.balanceInXsd,
    required this.tokenName,
    this.onTap,
  }) : super(key: key);

  final String balance;
  final String symbol;
  final String balanceInXsd;
  final String tokenName;
  final String logoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorsTheme.of(context).primaryBackground),
                    height: 40,
                    width: 40,
                    child: SvgPicture.network(logoUrl)),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 2,
                    ),
                    SizedBox(
                      width: 180,
                      child: Text(
                        tokenName,
                        style: FontTheme.of(context).body1().copyWith(
                              overflow: TextOverflow.ellipsis,
                            ),
                        softWrap: true,
                      ),
                    ),
                    Text(
                      symbol,
                      style: FontTheme.of(context).body1().copyWith(
                          overflow: TextOverflow.ellipsis,
                          color: ColorsTheme.of(context).white400),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance.toString(),
                  style: FontTheme.of(context).caption1().copyWith(
                        fontSize: 16,
                      ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  '$balanceInXsd XSD',
                  style: FontTheme.of(context)
                      .subtitle1()
                      .copyWith(color: ColorsTheme.of(context).white400),
                ),
              ],
            ),
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ColorsTheme.of(context).white400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
