import 'package:equatable/equatable.dart';

class NotificationsState with EquatableMixin {
  bool isNotificationsEnabled = false;

  @override
  List<Object?> get props => [isNotificationsEnabled];
}
