import 'package:moonchain_wallet/common/common.dart';
import 'package:moonchain_wallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../network_unavailable_use_case.dart';

final networkUnavailableWrapperPresenterContainer =
    PresenterContainer<NetworkUnavailableWrapperPresenterPresenter, void>(
  () => NetworkUnavailableWrapperPresenterPresenter(),
);

class NetworkUnavailableWrapperPresenterPresenter
    extends CompletePresenter<void> {
  NetworkUnavailableWrapperPresenterPresenter() : super(null);

  late final NetworkUnavailableUseCase _networkUnavailableUseCase =
      ref.read(networkUnavailableUseCaseProvider);

  @override
  void initState() {
    super.initState();
    listen<bool>(_networkUnavailableUseCase.stream, (available) {
      if (!available) {
        showTip();
      }
    });

    listen<bool>(_networkUnavailableUseCase.weakConnectionStream, (isWeak) {
      if (isWeak) {
        showWeakConnectionTip();
      }
    });
    checkNetwork();
  }

  Future<bool> checkNetwork() async {
    return await _networkUnavailableUseCase.check();
  }

  Future<bool> checkWeakConnection() async {
    return await _networkUnavailableUseCase.checkWeakConnection();
  }

  void showTip() {
    showSnackBar(
      context: context!,
      type: SnackBarType.warning,
      content: FlutterI18n.translate(context!, 'lost_internet_connection'),
      action: SnackBarAction(
        label: FlutterI18n.translate(context!, 'retry'),
        textColor: ColorsTheme.of(context!, listen: false).black300,
        onPressed: () async {
          if (!(await checkNetwork())) {
            showTip.call();
          }
        },
      ),
      snackBarPosition: SnackBarPosition.top,
    );
  }

  void showWeakConnectionTip() {
    showSnackBar(
      context: context!,
      type: SnackBarType.warning,
      content: FlutterI18n.translate(context!, 'poor_internet_connection'),
      action: SnackBarAction(
        label: FlutterI18n.translate(context!, 'retry'),
        textColor: ColorsTheme.of(context!, listen: false).black300,
        onPressed: () async {
          if (!(await checkWeakConnection())) {
            showWeakConnectionTip.call();
          }
        },
      ),
      snackBarPosition: SnackBarPosition.top,
    );
  }
}
