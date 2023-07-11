import 'package:equatable/equatable.dart';

class AppNavBarState with EquatableMixin {
  List<String> accounts = [];
  String currentAccount = '';

  @override
  List<Object?> get props => [
        accounts,
        currentAccount,
      ];
}
