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
import 'widgets/bg_service_information_widget.dart';
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
    final frequency = getPeriodicalCallDurationFromInt(
        notificationsState.periodicalCallData!.duration);

    final isMXCChains = Config.isMxcChains(notificationsState.network!.chainId);
    final bgServiceEnabled =
        notificationsState.periodicalCallData!.serviceEnabled;

    final isSettingsChangeEnabled = isMXCChains && bgServiceEnabled;

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
            enabled: true,
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
          SwitchRowItem(
            title: translate('background_notifications'),
            value: notificationsState.periodicalCallData!.serviceEnabled,
            onChanged: notificationsPresenter.changeEnableService,
            enabled: isMXCChains,
            textTrailingWidget: const BGServiceInformation(),
          ),
          const SizedBox(height: Sizes.spaceNormal),
          MXCDropDown(
            key: const Key('bgNotificationsFrequencyDropDown'),
            onTap: notificationsPresenter.showBGFetchFrequencyDialog,
            selectedItem: frequency.toStringFormatted(),
            enabled: isSettingsChangeEnabled &&
                notificationsState.periodicalCallData!.serviceEnabled,
          ),
          const SizedBox(height: Sizes.spaceNormal),
          SwitchRowItem(
            title: translate('low_balance'),
            value:
                notificationsState.periodicalCallData!.lowBalanceLimitEnabled,
            onChanged: notificationsPresenter.enableLowBalanceLimit,
            enabled: isSettingsChangeEnabled,
          ),
          MxcTextField(
            key: const ValueKey('lowBalanceTextField'),
            hint: 'e.g 1000',
            controller: ref.read(presenter).lowBalanceController,
            keyboardType: TextInputType.number,
            action: TextInputAction.next,
            suffixText: ref.watch(state).network!.symbol,
            readOnly: !isSettingsChangeEnabled ||
                !notificationsState.periodicalCallData!.lowBalanceLimitEnabled,
            hasClearButton: false,
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
            onFocused: (focused) => focused
                ? null
                : notificationsState.formKey.currentState!.validate(),
          ),
          const SizedBox(height: Sizes.spaceNormal),
          SwitchRowItem(
            title: translate('expected_transaction_fee'),
            value: notificationsState
                .periodicalCallData!.expectedTransactionFeeEnabled,
            onChanged: notificationsPresenter.enableExpectedGasPrice,
            enabled: isSettingsChangeEnabled,
          ),
          MxcTextField(
            key: const ValueKey('expectedTransactionFeeTextField'),
            hint: 'e.g 300',
            controller: ref.read(presenter).transactionFeeController,
            keyboardType: TextInputType.number,
            action: TextInputAction.next,
            suffixText: ref.watch(state).network!.symbol,
            readOnly: !isSettingsChangeEnabled ||
                !notificationsState
                    .periodicalCallData!.expectedTransactionFeeEnabled,
            hasClearButton: false,
            validator: (value) {
              value = ref.read(presenter).transactionFeeController.text;
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
            onFocused: (focused) => focused
                ? null
                : notificationsState.formKey.currentState!.validate(),
          ),
          const SizedBox(height: Sizes.spaceNormal),
          SwitchRowItem(
            title: translate('expected_epoch_occur'),
            value: notificationsState
                .periodicalCallData!.expectedEpochOccurrenceEnabled,
            onChanged: notificationsPresenter.enableExpectedEpochQuantity,
            enabled: isSettingsChangeEnabled,
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
            enabled: isSettingsChangeEnabled &&
                notificationsState
                    .periodicalCallData!.expectedEpochOccurrenceEnabled,
          ),
        ],
      ),
    );
  }
}
