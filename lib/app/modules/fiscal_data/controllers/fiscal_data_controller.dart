import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/fiscal_data_model.dart';
import 'package:restic_movil/app/data/repositories/fiscal_data_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

class FiscalDataController extends GetxController {
  final FiscalDataRepository _repository = Get.find<FiscalDataRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  late FormGroup form;

  final isEditing = false.obs;
  String? _currentFiscalDataId;
  String? _branchId;

  // Options for tax regime
  final taxRegimes = ['SIMPLE', 'ORDINARIO', 'NO_RESPONSABLE_IVA'];

  @override
  void onInit() {
    super.onInit();
    _initForm();
  }

  @override
  void onReady() {
    super.onReady();
    loadFiscalData();
  }

  /* inicializa el formulario con reactive_forms */
  void _initForm() {
    form = FormGroup({
      'businessName': FormControl<String>(
        validators: [Validators.required, Validators.maxLength(200)],
      ),
      'taxId': FormControl<String>(
        validators: [
          Validators.required,
          Validators.maxLength(15),
          Validators.minLength(6),
          Validators.pattern(RegExp(r'^[0-9]+$')),
        ],
      ),
      'taxIdDigit': FormControl<String>(validators: [Validators.maxLength(2)]),
      'address': FormControl<String>(
        validators: [Validators.required, Validators.maxLength(300)],
      ),
      'city': FormControl<String>(
        validators: [Validators.required, Validators.maxLength(100)],
      ),
      'department': FormControl<String>(
        validators: [Validators.maxLength(100)],
      ),
      'dianResolution': FormControl<String>(
        validators: [Validators.required, Validators.maxLength(100)],
      ),
      'resolutionStartDate': FormControl<String>(),
      'resolutionEndDate': FormControl<String>(),
      'invoicePrefix': FormControl<String>(
        validators: [Validators.maxLength(10)],
      ),
      'resolutionNumberFrom': FormControl<int>(),
      'resolutionNumberTo': FormControl<int>(),
      'taxRegime': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
          Validators.maxLength(100),
        ],
      ),
      'phone': FormControl<String>(validators: [Validators.maxLength(20)]),
      'website': FormControl<String>(validators: [Validators.maxLength(200)]),
    });
  }

  /* carga la data fiscal actual consultando el active end point */
  Future<void> loadFiscalData() async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          _branchId = await _storageService.getBranchId();

          if (_branchId == null) {
            Get.showSnackbar(
              const ErrorSnackbar('No se encontró sucursal configurada'),
            );
            return;
          }

          final data = await _repository.getActiveFiscalData(_branchId!);

          if (data != null) {
            isEditing.value = true;
            _currentFiscalDataId = data.id;
            form.patchValue(data.toJson());
          } else {
            isEditing.value = false;
            _currentFiscalDataId = null;
          }
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(message));
        }
      },
    );
  }

  /* guarda la información fiscal (creación o actualización) */
  Future<void> submit() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    if (_branchId == null) {
      Get.showSnackbar(
        const ErrorSnackbar('No se encontró sucursal configurada'),
      );
      return;
    }

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final formData = Map<String, dynamic>.from(form.value);
          formData['branchId'] = _branchId;

          final fiscalData = FiscalDataModel.fromJson(formData);

          if (isEditing.value && _currentFiscalDataId != null) {
            await _repository.updateFiscalData(
              _currentFiscalDataId!,
              fiscalData,
            );
            _showSuccessModal('Datos fiscales actualizados correctamente');
          } else {
            final created = await _repository.createFiscalData(fiscalData);
            _currentFiscalDataId = created.id;
            isEditing.value = true;
            _showSuccessModal('Datos fiscales creados correctamente');
          }
        } catch (e, t) {
          print(e);
          print(t);
          print(" Error en submit fiscal data");
          final message = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(message));
        }
      },
    );
  }

  /* Muestra modal de éxito y regresa al drawer al aceptar */
  void _showSuccessModal(String message) {
    Get.dialog(
      ModalInfo(
        title: 'Éxito',
        message: message,
        onClose: () {
          Get.back(); // close modal
          Get.back(); // regresa a donde se llamó, por diseño de Drawer que llama Get.toNamed, el back mandará al Home o previo.
        },
      ),
      barrierDismissible: false,
    );
  }
}
