import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:datadashwallet/core/core.dart';
import 'package:f_logs/f_logs.dart';
import 'customer_support_state.dart';

final customerSupportContainer =
    PresenterContainer<CustomerSupportPresenter, CustomerSupportState>(
        () => CustomerSupportPresenter());

class CustomerSupportPresenter extends CompletePresenter<CustomerSupportState> {
  CustomerSupportPresenter() : super(CustomerSupportState());

  final AppinioSocialShare _socialShare = AppinioSocialShare();

  void exportedLogs() async {
    loading = true;
    try {
      final file = await FLog.exportLogs();
      await _socialShare.shareToSystem(
        translate('export_logs')!,
        '',
        filePath: file.path,
      );

      addMessage(translate('exported_logs_successfully'));
    } catch (e, s) {
      addError(e, s);
    } finally {
      loading = false;
    }
  }
}
