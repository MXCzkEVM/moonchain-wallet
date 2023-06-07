import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:datadashwallet/features/home/home.dart';
import 'package:datadashwallet/common/common.dart';

import 'apps_tab_presenter.dart';
import 'apps_tab_state.dart';

class AppsTab extends HomeBasePage with HomeScreenMixin {
  const AppsTab({Key? key}) : super(key: key);

  @override
  ProviderBase<AppsTabPagePresenter> get presenter =>
      appsTabPageContainer.actions;

  @override
  ProviderBase<AppsTabPageState> get state => appsTabPageContainer.state;

  @override
  int get bottomNavCurrentIndex => 1;

  @override
  List<Widget> setContent(BuildContext context, WidgetRef ref) {
    return const [];
  }
}
