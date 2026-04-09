import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/payment_method_model.dart';
import 'package:restic_movil/app/data/repositories/payment_methods_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class PaymentMethodsController extends GetxController {
  final PaymentMethodsRepository repository;
  final StorageService _storageService = Get.find<StorageService>();

  PaymentMethodsController(this.repository);

  final RxList<PaymentMethodModel> methods = <PaymentMethodModel>[].obs;
  
  final form = FormGroup({
    'method': FormControl<String>(validators: [Validators.required]),
    'displayName': FormControl<String>(validators: [Validators.required, Validators.maxLength(80)]),
    'active': FormControl<bool>(value: false, validators: [Validators.required]),
    'displayOrder': FormControl<int>(validators: [Validators.required, Validators.min(1)]),
  });

  @override
  void onReady() {
    super.onReady();
    loadMethods();
  }

  Future<void> loadMethods() async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final result = await repository.getPaymentMethodsAll();
          result.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
          methods.assignAll(result);
        } catch (e) {
          Get.showSnackbar(ErrorSnackbar(ExceptionHandler.extractMessage(e)));
        }
      }
    );
  }

  void prepareEdit(PaymentMethodModel method) {
    form.reset();
    form.control('method').value = method.method;
    form.control('displayName').value = method.displayName ?? '';
    form.control('active').value = method.active ?? false;
    form.control('displayOrder').value = method.displayOrder ?? 1;
  }

  Future<void> updateMethod() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    final values = form.value;
    final methodKey = values['method'] as String;

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await repository.updatePaymentMethod(methodKey, {
            'method': methodKey,
            'displayName': values['displayName'],
            'active': values['active'],
            'displayOrder': values['displayOrder'],
          });
          
          // Refresh list and local storage (invalidate cash register cache intuitively)
          await _storageService.deletePaymentMethods();
          
          await loadMethods();
          Get.back(); // close modal
          Get.showSnackbar(const InfoSnackbar('Método de pago actualizado exitosamente'));
        } catch (e) {
          Get.showSnackbar(ErrorSnackbar(ExceptionHandler.extractMessage(e)));
        }
      }
    );
  }
}
