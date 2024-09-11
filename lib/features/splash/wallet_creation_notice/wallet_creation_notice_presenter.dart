import 'package:moonchain_wallet/core/core.dart';

import '../splash.dart';

final walletCreationNoticeContainer =
    PresenterContainer<WalletCreationNoticePresenter, void>(
        () => WalletCreationNoticePresenter());

class WalletCreationNoticePresenter extends CompletePresenter<void> {
  WalletCreationNoticePresenter() : super(null);

  Future<void> continueNow() => pushMNSAnnouncementPage(context!);
}
