import 'package:equatable/equatable.dart';

class SplashBasePageState with EquatableMixin {
  Map applist = {};

  @override
  List<Object?> get props => [
        applist,
      ];
}
