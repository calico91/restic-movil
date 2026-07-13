import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/repositories/cash_withdrawals_repository.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_reason.dart';
import 'package:restic_movil/app/data/models/cash_withdrawal_payment_source.dart';
import 'package:restic_movil/app/data/models/create_cash_withdrawal_request.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';

class ExpensesController extends GetxController {
  final CashWithdrawalsRepository _repository = Get.find();
  final StorageService _storageService = Get.find();

  final reasons = <CashWithdrawalReason>[].obs;
  final paymentSources = <CashWithdrawalPaymentSource>[].obs;

  late FormGroup form;

  @override
  void onInit() {
    super.onInit();
    _initForm();
  }

  @override
  void onReady() {
    super.onReady();
    _loadData();
  }

  void _initForm() {
    form = FormGroup({
      'amount': FormControl<double>(validators: [Validators.required]),
      'concept': FormControl<String>(validators: [Validators.required]),
      'voucherReference': FormControl<String>(),
      'reason': FormControl<CashWithdrawalReason>(
        validators: [Validators.required],
      ),
      'paymentSource': FormControl<CashWithdrawalPaymentSource>(
        validators: [Validators.required],
      ),
      'bankAccountName': FormControl<String>(),
      'bankAccountReference': FormControl<String>(),
    });

    // Listener para validar bankAccountName y referncia si es BANK_ACCOUNT
    form.control('paymentSource').valueChanges.listen((value) {
      final source = value as CashWithdrawalPaymentSource?;

      if (source?.name == 'BANK_ACCOUNT') {
        form.control('bankAccountName').setValidators([Validators.required]);
        // No se especificó si reference es requerida, pero en el JSON está. Lo dejo opcional segun instrucciones, o sigo bankAccountName que es obligatorio.
        // User said: "bankAccountName solo lo debes mostrar si paymentSource se selecciona BANK_ACCOUNT y es obligatorio solo en este caso"
      } else {
        form.control('bankAccountName').setValidators([]);
        form.control('bankAccountName').value = null;
        form.control('bankAccountReference').value = null;
      }
      form.control('bankAccountName').updateValueAndValidity();
    });
  }

  Future<void> _loadData() async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final results = await Future.wait([
            _repository.getReasons(),
            _repository.getPaymentSources(),
          ]);
          reasons.assignAll(results[0] as List<CashWithdrawalReason>);
          paymentSources.assignAll(
            results[1] as List<CashWithdrawalPaymentSource>,
          );
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  Future<void> submit() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final user = await _storageService.getUser();
          if (user?.id == null) {
            throw Exception('No se pudo obtener el usuario actual');
          }

          final formValue = form.value;
          final reason = formValue['reason'] as CashWithdrawalReason;
          final source =
              formValue['paymentSource'] as CashWithdrawalPaymentSource;

          final request = CreateCashWithdrawalRequest(
            amount: formValue['amount'] as double,
            concept: formValue['concept'] as String,
            paymentSource: source.name,
            reason: reason.name,
            userId: user!.id!,
            voucherReference: formValue['voucherReference'] as String?,
            bankAccountName: formValue['bankAccountName'] as String?,
            bankAccountReference: formValue['bankAccountReference'] as String?,
          );

          await _repository.createWithdrawal(request);

          Get.dialog(
            ModalInfo(
              title: 'Éxito',
              message: 'Salida de caja registrada correctamente',
              onClose: () {
                Get.back(); // Cerrar modal
                form.reset();
              },
            ),
          );
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }
}
