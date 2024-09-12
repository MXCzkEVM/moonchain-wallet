import 'package:moonchain_wallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'add_bookmark_presenter.dart';

class AddBookmark extends HookConsumerWidget {
  const AddBookmark({Key? key}) : super(key: key);

  @override
  ProviderBase<AddBookmarkPresenter> get presenter =>
      addBookmarkPageContainer.actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage.layer(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<TextEditingValue>(
            valueListenable: ref.watch(presenter).urlController,
            builder: (ctx, urlValue, _) {
              return MxcAppBarEvenly.text(
                titleText: translate('add_x')
                    .replaceFirst('{0}', translate('bookmark')),
                actionText: translate('save'),
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
            style: FontTheme.of(context).body1.secondary().copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
