import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../../../common/mixin/mixin.dart';
import 'home_base_page_presenter.dart';
import 'home_base_page_state.dart';

abstract class HomeBasePage extends HookConsumerWidget
    with HomeScreenMixin {
  const HomeBasePage({Key? key}) : super(key: key);

  List<Widget> setContent(BuildContext context, WidgetRef ref);

  int get bottomNavCurrentIndex;

  ProviderBase<HomeBasePagePresenter> get presenter;

  ProviderBase<HomeBasePageState> get state;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MxcPage(
      appBar: appBar(context),
      presenter: ref.read(presenter),
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorsTheme.of(context).primaryBackground,
      bottomNavigationBar: bottomNavigationBar(context, bottomNavCurrentIndex),
      layout: LayoutType.column,
      useContentPadding: false,
      childrenPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      children: setContent(context, ref)
      );
  }
}
