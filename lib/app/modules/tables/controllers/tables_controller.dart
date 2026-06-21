import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/table_model.dart';
import 'package:restic_movil/app/data/models/table_status_model.dart';
import 'package:restic_movil/app/data/repositories/tables_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class TablesController extends GetxController {
  final TablesRepository repository;

  TablesController({required this.repository});
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  final RxList<TableModel> tables = <TableModel>[].obs;
  final RxList<TableStatusDTO> statuses = <TableStatusDTO>[].obs;
  final RxSet<String> selectedTableIds = <String>{}.obs;

  late FormGroup tableForm;
  final RxBool isEditing = false.obs;
  String? editingTableId;

  @override
  void onReady() {
    super.onReady();
    _initForm();
    _loadInitialData();
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  /// Inicializa el formulario reactivo
  void _initForm() {
    tableForm = FormGroup({
      'name': FormControl<String>(validators: [Validators.required]),
      'status': FormControl<String>(validators: [Validators.required]),
      'location': FormControl<String>(),
      'tableNumber': FormControl<int>(), // Remover Validators.min(1) para evitar fallos si es nulo
    });
  }

  /// Carga los datos iniciales de las mesas y los estados disponibles
  Future<void> _loadInitialData() async {
    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final results = await Future.wait([
            repository.getTables(),
            repository.getStatuses(),
          ]);
          tables.value = results[0] as List<TableModel>;
          statuses.value = results[1] as List<TableStatusDTO>;
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
    );
  }

  /// Prepara el formulario para crear una nueva mesa
  void prepareCreate() {
    isEditing.value = false;
    editingTableId = null;
    tableForm.reset(value: {
      'status': 'AVAILABLE',
    });
  }

  /// Prepara el formulario para editar una mesa existente
  void prepareEdit(TableModel table) {
    isEditing.value = true;
    editingTableId = table.id;
    tableForm.reset(
      value: {
        'name': table.name,
        'status': table.status,
        'location': table.location,
        'tableNumber': table.tableNumber,
      },
    );
  }

  /// Crea o actualiza una mesa dependiendo del estado (isEditing)
  Future<void> saveTable() async {
    if (tableForm.invalid) {
      tableForm.markAllAsTouched();
      return;
    }

    final tableData = {
      'name': tableForm.control('name').value as String,
      'status': tableForm.control('status').value as String,
      if (tableForm.control('location').value != null &&
          (tableForm.control('location').value as String).isNotEmpty)
        'location': tableForm.control('location').value as String,
      if (isEditing.value && tableForm.control('tableNumber').value != null)
        'tableNumber': tableForm.control('tableNumber').value as int,
    };

    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          String modalTitle = '';
          String modalMessage = '';

          if (isEditing.value && editingTableId != null) {
            final response = await repository.updateTable(
              editingTableId!,
              tableData,
            );
            modalTitle = 'Mesa Actualizada';
            modalMessage =
                'La mesa "${response.name}" ha sido actualizada exitosamente.';
          } else {
            final response = await repository.createTables([tableData]);
            modalTitle = 'Mesa Creada';
            modalMessage = response.isNotEmpty
                ? 'La mesa "${response.first.name}" ha sido creada exitosamente.'
                : 'La mesa ha sido creada exitosamente.';
          }
          await _loadDataWithoutOverlay();
          Get.back(); // Cerrar modal del formulario

          // Mostrar modal informativo
          Get.dialog(
            ModalInfo(
              title: modalTitle,
              message: modalMessage,
              buttonText: 'Cerrar',
              onClose: () => Get.back(),
            ),
          );
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
    );
  }

  /// Elimina una mesa seleccionada
  Future<void> deleteTable(String id) async {
    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await repository.deleteTable(id);
          selectedTableIds.remove(id);
          Get.showSnackbar(const InfoSnackbar('Mesa eliminada'));
          await _loadDataWithoutOverlay();
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
    );
  }

  /// Carga datos sin renderizar el overlay de loading
  Future<void> _loadDataWithoutOverlay() async {
    try {
      tables.value = await repository.getTables();
    } catch (e) {
      debugPrint('Error reloading tables: $e');
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'OCCUPIED':
        return Colors.orange;
      case 'RESERVED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /* Obtiene el nombre descriptivo del estado a partir del código */
  String getStatusName(String? status) {
    return statuses.firstWhereOrNull((e) => e.name == status)?.description ??
        status ??
        'Desconocido';
  }

  /// Verifica si una mesa está seleccionada
  bool isTableSelected(String id) => selectedTableIds.contains(id);

  /// Alterna la selección de una mesa
  void toggleTableSelection(String id) {
    if (selectedTableIds.contains(id)) {
      selectedTableIds.remove(id);
    } else {
      selectedTableIds.add(id);
    }
  }

  /// Limpia la selección actual de mesas
  void clearSelection() {
    selectedTableIds.clear();
  }

  /// Verifica si se pueden reservar las mesas seleccionadas
  bool get canReserveSelected {
    if (selectedTableIds.isEmpty) return false;
    final selected = tables.where((t) => selectedTableIds.contains(t.id));
    return selected.every((t) => t.status == 'AVAILABLE');
  }

  /// Verifica si se pueden liberar las mesas seleccionadas
  bool get canReleaseSelected {
    if (selectedTableIds.isEmpty) return false;
    final selected = tables.where((t) => selectedTableIds.contains(t.id));
    return selected.every((t) => t.status != 'AVAILABLE');
  }

  /// Reserva todas las mesas seleccionadas
  Future<void> reserveSelectedTables() async {
    if (selectedTableIds.isEmpty) return;

    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await repository.reserveTables(selectedTableIds.toList());
          Get.showSnackbar(const InfoSnackbar('Mesas reservadas exitosamente'));
          clearSelection();
          await _loadDataWithoutOverlay();
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
    );
  }

  /// Libera todas las mesas seleccionadas
  Future<void> releaseSelectedTables() async {
    if (selectedTableIds.isEmpty) return;

    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await repository.releaseTables(selectedTableIds.toList());
          Get.showSnackbar(const InfoSnackbar('Mesas liberadas exitosamente'));
          clearSelection();
          await _loadDataWithoutOverlay();
        } catch (e) {
          final String errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
    );
  }
}
