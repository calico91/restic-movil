import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/cashier_user_model.dart';
import 'package:restic_movil/app/data/models/terminal_model.dart';
import 'package:restic_movil/app/data/repositories/cashier_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class OpenShiftController extends GetxController {
  final CashierRepository _repository;

  OpenShiftController(this._repository);

  final form = FormGroup({
    'cashierId': FormControl<String>(validators: [Validators.required]),
    'initialAmount': FormControl<double>(
      validators: [Validators.required, Validators.min(0)],
    ),
    'terminalId': FormControl<String>(validators: [Validators.required]),
    'remarks': FormControl<String>(validators: [Validators.maxLength(250)]),
  });

  final RxList<CashierUser> users = <CashierUser>[].obs;
  final RxList<Terminal> terminals = <Terminal>[].obs;

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final usersData = await _repository.getAdminAndCashierUsers();
          final terminalsData = await _repository.getTerminals();

          users.assignAll(usersData);
          terminals.assignAll(terminalsData);
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }

  Future<void> submit() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    final cashierId = form.control('cashierId').value as String;
    final initialAmount = form.control('initialAmount').value as double;
    final terminalId = form.control('terminalId').value as String;
    final remarks = form.control('remarks').value as String?;

    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await _repository.openShift(
            cashierId: cashierId,
            initialAmount: initialAmount,
            terminalId: terminalId,
            remarks: remarks,
          );
          Get.back();
          Get.showSnackbar(
            const InfoSnackbar('Apertura de caja realizada correctamente'),
          );
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }
}
