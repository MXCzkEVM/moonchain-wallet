import 'package:equatable/equatable.dart';
import 'package:datadashwallet/features/splash/splash.dart';

class SplashSetupWalletPageState extends SplashBasePageState with EquatableMixin {
  Map applist = {};

  @override
  List<Object?> get props => [
        applist,
      ];
}
