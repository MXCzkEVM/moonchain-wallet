import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_dapp_presenter.dart';
import 'add_dapp_state.dart';

class AddDApp extends HookConsumerWidget {
  const AddDApp({Key? key}) : super(key: key);

  @override
  ProviderBase<AddDAppPresenter> get presenter => addDAppPageContainer.actions;

  @override
  ProviderBase<AddDAppPageState> get state => addDAppPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => BottomFlowDialog.of(context).close(),
                child: Text(
                  FlutterI18n.translate(context, 'cancel'),
                  style: FontTheme.of(context).body1(),
                ),
              ),
              Text(
                FlutterI18n.translate(context, 'add_bookmark'),
                style: FontTheme.of(context).body2(),
              ),
              InkWell(
                onTap: () => ref.watch(presenter).onSave(),
                child: Text(
                  FlutterI18n.translate(context, 'save'),
                  style: FontTheme.of(context).body2.secondary(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            FlutterI18n.translate(context, 'enter_bookmark_url'),
            style: FontTheme.of(context).body2.secondary(),
          ),
        ),
        MxcTextfield(
          controller: ref.watch(state).urlController,
        ),
      ],
    );
  }
}
