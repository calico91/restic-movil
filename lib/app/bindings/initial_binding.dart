import 'package:get/get.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PrinterService>(PrinterService(), permanent: true);
  }
}
