import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../dapps_presenter.dart';

class DAppProviderHeader extends HookConsumerWidget {
  final String providerTitle;
  final List<Dapp> dapps;
  const DAppProviderHeader(
     {
    super.key,
    required this.dapps,
    required this.providerTitle,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(appsPagePageContainer.state);
    final actions = ref.read(appsPagePageContainer.actions);

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Text(
              providerTitle,
              style: FontTheme.of(context).h7().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: ColorsTheme.of(context).textPrimary),
            ),
            const Spacer(),
            InkWell(
              onTap: () => actions.selectSeeAllDApps(dapps),
              child: Text(
                FlutterI18n.translate(context, 'see_all'),
                style: FontTheme.of(context).h7().copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF00AEFF)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
