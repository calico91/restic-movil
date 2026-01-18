import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/origin_type.dart';
import 'package:restic_movil/app/data/repositories/orders_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';

class TakeOrderController extends GetxController {
  final OrdersRepository ordersRepository;
  final StorageService storageService;

  TakeOrderController({
    required this.ordersRepository,
    required this.storageService,
  });

  final form = FormGroup({
    'origin': FormControl<String>(validators: [Validators.required]),
  });

  final RxList<OriginType> originTypes = <OriginType>[].obs;

  @override
  void onReady() {
    super.onReady();
    _loadOriginTypes();
  }

  Future<void> _loadOriginTypes() async {
    Get.showOverlay(
      loadingWidget: LoadingCharging(),
      asyncFunction: () async {
        try {
          final savedOrigins = await storageService.getOrderOrigins();

          if (savedOrigins != null && savedOrigins.isNotEmpty) {
            originTypes.assignAll(
              savedOrigins.map((e) => OriginType.fromJson(e)).toList(),
            );
          } else {
            final origins = await ordersRepository.getOriginTypes();
            originTypes.assignAll(origins);
            await storageService.saveOrderOrigins(
              origins.map((e) => e.toJson()).toList(),
            );
          }
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }

  void goBack() {
    Get.back();
  }
}
