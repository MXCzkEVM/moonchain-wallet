import 'package:equatable/equatable.dart';

class SplashBaseState with EquatableMixin {
  Map applist = {};
  bool isInstallEmail = false;

  bool animate = false;

  @override
  List<Object?> get props => [applist, isInstallEmail, animate];
}
