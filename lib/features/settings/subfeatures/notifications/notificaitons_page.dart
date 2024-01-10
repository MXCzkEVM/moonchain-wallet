import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/features/common/common.dart';
import 'package:datadashwallet/features/settings/subfeatures/notifications/widgets/epoch_occur_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_logic/mxc_logic.dart';
import 'package:mxc_ui/mxc_ui.dart';

import 'notifications_presenter.dart';
import 'notifications_state.dart';
import 'widgets/switch_row_item.dart';

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

    final expectedEpochOccur =
        notificationsState.periodicalCallData!.expectedEpochOccurrence;

    String translate(String text) => FlutterI18n.translate(context, text);

    return Form(
      key: notificationsState.formKey,
      child: MxcPage(
        presenter: ref.watch(presenter),
        crossAxisAlignment: CrossAxisAlignment.start,
        appBar: AppNavBar(
          title: Text(
            FlutterI18n.translate(context, 'notifications'),
            style: FontTheme.of(context).body1.primary(),
          ),
        ),
        children: [
          SwitchRowItem(
            title: translate('notifications'),
            value: notificationsState.isNotificationsEnabled,
            onChanged: notificationsPresenter.changeNotificationsState,
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
          ),
          const SizedBox(height: Sizes.spaceNormal),
          Text(
            translate('background_notifications_frequency'),
            style: FontTheme.of(context).body2.primary(),
          ),
          const SizedBox(height: Sizes.spaceNormal),
          MXCDropDown(
            key: const Key('bgNotificationsFrequencyDropDown'),
            onTap: () {
              showEpochOccurDialog(context,
                  onTap: notificationsPresenter.selectEpochOccur,
                  selectedOccur: notificationsState
                      .periodicalCallData!.expectedEpochOccurrence);
            },
            selectedItem: '$expectedEpochOccur  Epoch occurrence',
          ),
          const SizedBox(height: Sizes.spaceNormal),
          SwitchRowItem(
            title: translate('low_balance'),
            value:
                notificationsState.periodicalCallData!.lowBalanceLimitEnabled,
            onChanged: notificationsPresenter.enableLowBalanceLimit,
          ),
          MxcTextField(
            key: const ValueKey('lowBalanceTextField'),
            hint: 'e.g 300',
            controller: ref.read(presenter).lowBalanceController,
            keyboardType: TextInputType.number,
            action: TextInputAction.next,
            suffixText: ref.watch(state).network!.symbol,
            // readOnly: !notificationsState.periodicalCallData!.lowBalanceLimitEnabled
            validator: (value) {
              value = ref.read(presenter).lowBalanceController.text;
              final res = Validation.notEmpty(
                  context,
                  value,
                  translate('x_not_empty')
                      .replaceFirst('{0}', translate('amount')));
              if (res != null) {
                return res;
              }
              try {
                final doubleValue = double.parse(value);
                String stringValue = doubleValue.toString();

                int decimalPlaces = stringValue.split('.')[1].length;

                if (doubleValue.isNegative ||
                    decimalPlaces > Config.decimalWriteFixed) {
                  return translate('invalid_format');
                }
                return null;
              } catch (e) {
                return translate('invalid_format');
              }
            },
            // onChanged: (value) {
            //   if (!notificationsState.formKey.currentState!.validate()) return;
            // },
            onFocused: (focused) => focused
                ? null
                : notificationsState.formKey.currentState!.validate(),
          ),
          const SizedBox(height: Sizes.spaceNormal),
          SwitchRowItem(
            title: translate('expected_gas_price'),
            value:
                notificationsState.periodicalCallData!.expectedGasPriceEnabled,
            onChanged: notificationsPresenter.enableExpectedGasPrice,
          ),
          // MxcTextField(
          //   key: const ValueKey('addressTextField'),
          //   label: '${translate('token_contract_addresss')} *',
          //   hint: translate('enter_x').replaceFirst(
          //       '{0}', translate('token_contract_addresss').toLowerCase()),
          //   controller: ref.read(presenter).addressController,
          //   action: TextInputAction.done,
          //   validator: (value) {
          //     final res = Validation.notEmpty(
          //         context,
          //         value,
          //         translate('x_not_empty')
          //             .replaceFirst('{0}', translate('token_contract_addresss')));
          //     if (res != null) return res;

          //     return Validation.checkEthereumAddress(context, value!);
          //   },
          //   onChanged: (value) {
          //     if (!formKey.currentState!.validate()) return;
          //     ref.read(presenter).onChanged(value);
          //   },
          //   onFocused: (focused) =>
          //       focused ? null : formKey.currentState!.validate(),
          // ),
          const SizedBox(height: Sizes.spaceNormal),
          SwitchRowItem(
            title: translate('expected_epoch_occur'),
            value: notificationsState
                .periodicalCallData!.expectedEpochOccurrenceEnabled,
            onChanged: notificationsPresenter.enableExpectedEpochQuantity,
          ),
          const SizedBox(height: Sizes.spaceNormal),
          MXCDropDown(
            key: const Key('epochOccurrenceDropDown'),
            onTap: () {
              showEpochOccurDialog(context,
                  onTap: notificationsPresenter.selectEpochOccur,
                  selectedOccur: notificationsState
                      .periodicalCallData!.expectedEpochOccurrence);
            },
            selectedItem: '$expectedEpochOccur  Epoch occurrence',
          ),
          // Row(
          //   children: [
          //     Text(
          //       translate('notifications'),
          //       style: FontTheme.of(context).body2.primary(),
          //     ),
          //     const Spacer(),
          //     const SizedBox(
          //       width: 16,
          //     ),
          //     CupertinoSwitch(
          //       value: notificationsState.isNotificationsEnabled,
          //       onChanged: (value) =>
          //           notificationsPresenter.changeNotificationsState(value),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
