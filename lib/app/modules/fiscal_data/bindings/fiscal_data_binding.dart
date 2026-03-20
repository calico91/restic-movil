import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/fiscal_data_repository.dart';
import 'package:restic_movil/app/modules/fiscal_data/controllers/fiscal_data_controller.dart';

class FiscalDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FiscalDataRepository>(
      () => FiscalDataRepository(BaseHttpClient()),
    );
    Get.lazyPut<FiscalDataController>(() => FiscalDataController());
  }
}
