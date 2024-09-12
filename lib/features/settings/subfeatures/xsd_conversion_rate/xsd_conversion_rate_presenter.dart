import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';
import 'xsd_conversion_rate_state.dart';

final xsdConversionRateContainer =
    PresenterContainer<XsdConversionRatePresenter, XsdConversionRateState>(
        () => XsdConversionRatePresenter());

class XsdConversionRatePresenter
    extends CompletePresenter<XsdConversionRateState> {
  XsdConversionRatePresenter() : super(XsdConversionRateState());

  late final _accountUseCase = ref.watch(accountUseCaseProvider);
  late final TextEditingController rateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listen(_accountUseCase.xsdConversionRate, (value) {
      rateController.text = value.toString();
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void onReset() {
    final rate = rateController.text;

    loading = true;
    try {
      final data = double.parse(rate);
      if (_accountUseCase.xsdConversionRate.value == data) return;
      _accountUseCase.resetXsdConversionRate(data);
      addMessage('Reset xsd conversion rate successfully.');
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }
}
