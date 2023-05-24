import 'package:equatable/equatable.dart';

class SecuredStoragePageState with EquatableMixin {
  Map applist = {};

  @override
  List<Object?> get props => [
        applist,
      ];
}
