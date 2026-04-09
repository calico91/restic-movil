import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/payment_methods_repository.dart';
import 'package:restic_movil/app/modules/payment_methods/controllers/payment_methods_controller.dart';

class PaymentMethodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentMethodsRepository(Get.find<BaseHttpClient>()), fenix: true);
    Get.lazyPut(() => PaymentMethodsController(Get.find<PaymentMethodsRepository>()));
  }
}    
