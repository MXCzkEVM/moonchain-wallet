import 'package:equatable/equatable.dart';

class SplashBaseState with EquatableMixin {
  Map applist = {};
  bool isEmailAppAvailable = false;

  bool animate = false;

  @override
  List<Object?> get props => [applist, animate, isEmailAppAvailable];
}
