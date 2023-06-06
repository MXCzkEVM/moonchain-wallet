import 'package:equatable/equatable.dart';

class SplashBaseState with EquatableMixin {
  Map applist = {};
  bool isInstallEmail = false;

  @override
  List<Object?> get props => [
        applist,
        isInstallEmail,
      ];
}
