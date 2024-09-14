import 'package:moonchain_wallet/features/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mxc_ui/mxc_ui.dart';

import '../dapps_presenter.dart';

class EditModeAppBar extends HookConsumerWidget {
  const EditModeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dappsPresenter = ref.watch(appsPagePageContainer.actions);
    return AppNavBar(
      leading: EditModeButton(
        onTap: dappsPresenter.addBookmark,
        child: Icon(
          Icons.add,
          size: 20,
          color: ColorsTheme.of(context).screenBackground,
        ),
      ),
      action: EditModeButton(
        onTap: dappsPresenter.changeEditMode,
        child: Text(
          FlutterI18n.translate(context, 'done'),
          style: FontTheme.of(context).subtitle1().copyWith(
              color: ColorsTheme.of(context).screenBackground,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class EditModeButton extends StatelessWidget {
  const EditModeButton({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(30),
          ),
          color: ColorsTheme.of(context).iconPrimary,
        ),
        child: child,
      ),
    );
  }
}
