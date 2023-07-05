import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_token_presenter.dart';
import 'add_token_state.dart';

class AddToken extends HookConsumerWidget {
  const AddToken({Key? key}) : super(key: key);

  @override
  ProviderBase<AddTokenPresenter> get presenter =>
      addTokenPageContainer.actions;

  @override
  ProviderBase<AddTokenPageState> get state => addTokenPageContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

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
        Form(
          key: formKey,
          child: MxcTextField(
            key: const ValueKey('urlTextField'),
            controller: ref.watch(state).urlController,
            action: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}
