import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';

class CloseShiftController extends GetxController {
  final CashierRepository cashierRepository;
  final StorageService _storageService = Get.find<StorageService>();

  CloseShiftController({required this.cashierRepository});

  final form = FormGroup({
    'declaredCashAmount': FormControl<String>(
      validators: [Validators.required],
    ),
    'remarks': FormControl<String>(),
  });

  /*metodo para parsear montos formateados como string*/
  double _parseAmount(String value) {
    if (value.isEmpty) return 0.0;
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  /*Parsea el efectivo declarado desde el formulario. Util para mostrarlo en
  modales de confirmacion sin re-implementar la logica de limpieza. Devuelve 0.0
  si el control esta vacio o nulo.*/
  double parseDeclaredAmount() {
    final declaredCashStr = form.control('declaredCashAmount').value as String?;
    return _parseAmount(declaredCashStr ?? '');
  }

  /*metodo para enviar la solicitud de cierre de caja y retornar la respuesta para que la vista la procese*/
  Future<Map<String, dynamic>?> submitCloseShift() async {
    final loginResponse = await _storageService.getUser();
    final cashierId = loginResponse?.id;

    if (cashierId == null) {
      ErrorHandler.showErrorDialog('No se pudo identificar al usuario (Cajero).');
      return null;
    }

    final remarks = form.control('remarks').value as String?;

    final declaredCash = parseDeclaredAmount();

    if (declaredCash <= 0) {
      ErrorHandler.showErrorDialog('El efectivo declarado debe ser mayor a 0.');
      return null;
    }

    Map<String, dynamic>? resultResponse;

    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          resultResponse = await cashierRepository.closeShift(
            cashierId: cashierId,
            declaredCashAmount: declaredCash,
            remarks: remarks,
          );
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );

    return resultResponse;
  }
}
