import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadProviders();

  final container = ProviderContainer();
  final authUseCase = container.read(loginUseCaseProvider);
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
}
