import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:datadashwallet/features/settings/subfeatures/recipient/presentation/add_recipient/add_recipient_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'select_recipient_presenter.dart';
import 'select_recipient_state.dart';
import 'widgets/recipient_item.dart';

class SelectRecipientPage extends HookConsumerWidget {
  const SelectRecipientPage({Key? key}) : super(key: key);

  @override
  ProviderBase<SelectRecipientPresenter> get presenter =>
      addTokenPageContainer.actions;

  @override
  ProviderBase<SelectRecipientState> get state => addTokenPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(state).recipients;

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxcAppBarEvenly.back(
          titleText: translate('new_recipient'),
          actionText: translate('new'),
          onActionTap: () => Navigator.of(context)
              .push(route.featureDialog(const AddRecipientPage())),
        ),
        const SizedBox(height: 16),
        ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: data.length,
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              return RecipientItem(
                name: data[index].name,
                address: data[index].address ?? data[index].mns ?? '',
                onTap: () => Navigator.of(context).pop(data[index]),
              );
            }),
      ],
    );
  }
}
