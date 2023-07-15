import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_bookmark_presenter.dart';

class addBookmark extends HookConsumerWidget {
  const addBookmark({Key? key}) : super(key: key);

  @override
  ProviderBase<AddBookmarkPresenter> get presenter =>
      addBookmarkPageContainer.actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<TextEditingValue>(
            valueListenable: ref.watch(presenter).urlController,
            builder: (ctx, urlValue, _) {
              return MxcAppBarEvenly.text(
                titleText: FlutterI18n.translate(context, 'add_bookmark'),
                actionText: FlutterI18n.translate(context, 'save'),
                onActionTap: () {
                  if (!formKey.currentState!.validate()) return;
                  ref.watch(presenter).onSave();
                },
                isActionTap: urlValue.text.isNotEmpty,
              );
            }),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            FlutterI18n.translate(context, 'enter_bookmark_url'),
            style: FontTheme.of(context).body2.secondary(),
          ),
        ),
        Form(
          key: formKey,
          child: MxcTextField(
            key: const ValueKey('urlTextField'),
            label: 'URL',
            controller: ref.read(presenter).urlController,
            action: TextInputAction.done,
            validator: (v) => Validation.checkUrl(context, v),
          ),
        ),
      ],
    );
  }
}
