import 'package:equatable/equatable.dart';

class AppNavBarState with EquatableMixin {
  bool online = false;
  List<String> accounts = [];
  String currentAccount = '';

  @override
  List<Object?> get props => [
        online,
        accounts,
        currentAccount,
      ];
}
