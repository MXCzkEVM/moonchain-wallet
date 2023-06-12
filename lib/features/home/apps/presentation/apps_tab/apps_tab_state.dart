import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:equatable/equatable.dart';

class AppsTabPageState with EquatableMixin {
  List<AppCardEntity> appCards = List.from(AppCardEntity.getAppCards());

  @override
  List<Object?> get props => [
        appCards,
      ];
}
