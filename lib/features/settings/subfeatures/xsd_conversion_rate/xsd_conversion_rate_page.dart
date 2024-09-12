import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/features/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'xsd_conversion_rate_presenter.dart';
import 'xsd_conversion_rate_state.dart';

class XsdConversionRatePage extends HookConsumerWidget {
  const XsdConversionRatePage({Key? key}) : super(key: key);

  @override
  ProviderBase<XsdConversionRatePresenter> get presenter =>
      xsdConversionRateContainer.actions;

  @override
  ProviderBase<XsdConversionRateState> get state =>
      xsdConversionRateContainer.state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    String translate(String text) => FlutterI18n.translate(context, text);

    return MxcPage(
      presenter: ref.watch(presenter),
      crossAxisAlignment: CrossAxisAlignment.start,
      appBar: AppNavBar(
        title: Text(
          FlutterI18n.translate(context, 'xsd_conversion_rate'),
          style: FontTheme.of(context).body1.primary(),
        ),
      ),
      children: [
        Form(
          key: formKey,
          child: MxcTextField(
            key: const ValueKey('rateTextField'),
            controller: ref.read(presenter).rateController,
            action: TextInputAction.done,
            suffixText: 'USD',
            validator: (value) {
              final res = Validation.notEmpty(
                  context,
                  value,
                  translate('x_not_empty')
                      .replaceFirst('{0}', translate('xsd_conversion_rate')));
              if (res != null) return res;

              if (double.parse(value!) == 0.0) {
                return translate('xsd_conversion_rate_not_zero');
              }

              return null;
            },
            onFocused: (focused) =>
                focused ? null : formKey.currentState!.validate(),
          ),
        ),
        Text(
          FlutterI18n.translate(context, 'xsd_conversion_rate_note1'),
          style: FontTheme.of(context).subtitle1.secondary(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        Text(
          FlutterI18n.translate(context, 'xsd_conversion_rate_note2'),
          style: FontTheme.of(context).subtitle1.secondary(),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        Text(
          FlutterI18n.translate(context, 'xsd_conversion_rate_note3'),
          style: FontTheme.of(context).subtitle1.secondary().copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: Sizes.spaceNormal),
        ValueListenableBuilder<TextEditingValue>(
            valueListenable: ref.watch(presenter).rateController,
            builder: (ctx, rateValue, _) {
              return MxcButton.secondary(
                key: const ValueKey('resetXsdRateButton'),
                title: FlutterI18n.translate(context, 'reset_xsd_rate'),
                size: MXCWalletButtonSize.xl,
                edgeType: UIConfig.settingsScreensButtonsEdgeType,
                onTap: rateValue.text.isNotEmpty
                    ? () {
                        if (!formKey.currentState!.validate()) return;
                        ref.read(presenter).onReset();
                      }
                    : null,
              );
            }),
      ],
    );
  }
}
