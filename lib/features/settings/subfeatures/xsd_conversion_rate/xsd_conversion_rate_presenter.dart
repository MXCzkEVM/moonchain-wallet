import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'xsd_conversion_rate_state.dart';

final xsdConversionRateContainer =
    PresenterContainer<XsdConversionRatePresenter, XsdConversionRateState>(
        () => XsdConversionRatePresenter());

class XsdConversionRatePresenter
    extends CompletePresenter<XsdConversionRateState> {
  XsdConversionRatePresenter() : super(XsdConversionRateState());

  late final TextEditingController rateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    rateController.text = '2';
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  void onReset() {
    final rate = rateController.text;

    loading = true;
    try {} catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }
}
