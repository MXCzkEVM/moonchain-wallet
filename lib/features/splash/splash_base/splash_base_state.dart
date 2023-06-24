import 'package:equatable/equatable.dart';

class SplashBaseState with EquatableMixin {
  Map applist = {};
  bool isInstallEmail = false;

  bool showLogo = false;

  @override
  List<Object?> get props => [applist, isInstallEmail, showLogo];
}
