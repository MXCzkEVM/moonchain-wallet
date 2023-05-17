import 'package:equatable/equatable.dart';

class AppThemeState with EquatableMixin {
  bool darkMode = false;

  @override
  List<Object?> get props => [darkMode];
}
