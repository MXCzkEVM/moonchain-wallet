import 'package:equatable/equatable.dart';
import 'package:datadashwallet/features/home/home.dart';

import 'entities/app_card_entity.dart';

class AppsTabPageState extends HomeBasePageState with EquatableMixin {
  List<AppCardEntity> appCards = List.from(AppCardEntity.getAppCards());

  @override
  List<Object?> get props => [
        appCards,
      ];
}
