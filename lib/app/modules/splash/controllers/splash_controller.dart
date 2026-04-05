import 'package:get/get.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  /// Inicia el temporizador del splash screen
  void _startSplash() async {
    await Future.delayed(const Duration(seconds: 4));
    
    final token = await storageService.getToken();
    final branchId = await storageService.getBranchId();

    if (token != null && token.isNotEmpty && branchId != null && branchId.isNotEmpty) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
