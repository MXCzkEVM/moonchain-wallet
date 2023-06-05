import 'package:equatable/equatable.dart';

class SplashBaseState with EquatableMixin {
  Map applist = {};

  @override
  List<Object?> get props => [
        applist,
      ];
}
