import 'package:datadashwallet/core/core.dart';
import 'customer_support_state.dart';

final customerSupportContainer =
    PresenterContainer<CustomerSupportPresenter, CustomerSupportState>(() => CustomerSupportPresenter());

class CustomerSupportPresenter extends CompletePresenter<CustomerSupportState> {
  CustomerSupportPresenter() : super(CustomerSupportState());

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

}
