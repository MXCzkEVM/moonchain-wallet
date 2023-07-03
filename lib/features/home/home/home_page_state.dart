import 'package:equatable/equatable.dart';
import 'package:datadashwallet/features/home/home.dart';

class HomeState with EquatableMixin {
  // final currentIndex = 0;
  int _currentIndex = 0;
  set currentIndex(int value) => _currentIndex = value;
  int get currentIndex => _currentIndex;
  bool isEditMode = false;

  @override
  List<Object?> get props => [
        currentIndex,
        isEditMode,
      ];
}
