import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.analytics.Analytics;
import com.microsoft.appcenter.crashes.Crashes;

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadProviders();

  final container = ProviderContainer();
  final authUseCase = container.read(authUseCaseProvider);
  final isLoggedIn = authUseCase.loggedIn;

  await Biometric.load();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: DataDashWallet(
        isLoggedIn: isLoggedIn,
      ),
    ),
  );
  _startAppCenter();
}

Future<void> _startAppCenter() async {
  String appSecret = "d6920fcc-d680-42a1-afaf-4cf292d223ac";
  AppCenter.start(getApplication(), "d6920fcc-d680-42a1-afaf-4cf292d223ac", Analytics.class, Crashes.class);
  await AppCenter.start(appSecret: appSecret, enableAnalytics: true);
  await AppCenterAnalytics.setEnabled(true);
  await AppCenterCrashes.setEnabled(true);
}
