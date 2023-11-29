import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'notifications_presenter.dart';
import 'notifications_state.dart';

class NotificationsPage extends HookConsumerWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ProviderBase<NotificationsPresenter> get presenter =>
      notificationsContainer.actions;

  @override
  ProviderBase<NotificationsState> get state => notificationsContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(state);
    final notificationsPresenter = ref.read(presenter);

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: AppNavBar(
        title: Text(
          FlutterI18n.translate(context, 'notifications'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      children: [
        Row(
          children: [
            Text(
              translate('notifications'),
              style: FontTheme.of(context).body2.primary(),
            ),
            const Spacer(),
            const SizedBox(
              width: 16,
            ),
            CupertinoSwitch(
              value: notificationsState.isNotificationsEnabled,
              onChanged: (value) =>
                  notificationsPresenter.changeNotificationsState(value),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.spaceNormal),
            Text(
              translate('why_enable_notifications'),
              style: FontTheme.of(context).subtitle1.primary(),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: Sizes.spaceNormal),
            Text(
              translate('why_enable_notifications_notice'),
              style: FontTheme.of(context).subtitle1.secondary(),
              textAlign: TextAlign.justify,
            ),
          ],
        )
      ],
    );
  }
}
