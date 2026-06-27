import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';
import 'package:restic_movil/app/data/models/stock_movement_model.dart';
import 'package:restic_movil/app/data/repositories/inventory_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/modules/inventory/views/widgets/inventory_item_form_dialog.dart';
import 'package:restic_movil/app/modules/inventory/views/widgets/manual_movement_dialog.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';

class InventoryController extends GetxController {
  final InventoryRepository _inventoryRepository;
  final StorageService _storageService = Get.find<StorageService>();

  InventoryController(this._inventoryRepository);

  final RxInt selectedTab = 0.obs;
  final RxList<InventoryItemModel> items = <InventoryItemModel>[].obs;
  final RxList<InventoryItemModel> alerts = <InventoryItemModel>[].obs;
  final RxList<StockMovementModel> movements = <StockMovementModel>[].obs;
  final RxBool canEdit = false.obs;

  final FormGroup itemForm = FormGroup({
    'name': FormControl<String>(validators: [Validators.required]),
    'unit': FormControl<String>(value: 'UNIT', validators: [Validators.required]),
    'currentStock': FormControl<double>(value: 0.0, validators: [Validators.required, Validators.min(0)]),
    'minStock': FormControl<double>(value: 0.0, validators: [Validators.required, Validators.min(0)]),
  });

  final FormGroup movementForm = FormGroup({
    'inventoryItemId': FormControl<String>(validators: [Validators.required]),
    'type': FormControl<String>(value: 'PURCHASE', validators: [Validators.required]),
    'quantity': FormControl<double>(value: 0.0, validators: [Validators.required, Validators.min(0.001)]),
    'notes': FormControl<String>(),
  });

  @override
  void onReady() {
    super.onReady();
    _loadPermissions();
    loadAll();
  }

  /// Carga en paralelo insumos, alertas y movimientos para renderizar el modulo.
  Future<void> loadAll() async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final result = await Future.wait([
            _inventoryRepository.getItems(),
            _inventoryRepository.getAlerts(),
            _inventoryRepository.getMovements(),
          ]);
          items.assignAll(result[0] as List<InventoryItemModel>);
          alerts.assignAll(result[1] as List<InventoryItemModel>);
          movements.assignAll(result[2] as List<StockMovementModel>);
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: message));
        }
      },
    );
  }

  /// Carga roles del usuario para habilitar o deshabilitar acciones de escritura.
  Future<void> _loadPermissions() async {
    final user = await _storageService.getUser();
    final roles = user?.roles ?? [];
    canEdit.value = roles.contains('SUPER') || roles.contains('ADMINISTRADOR');
  }

  /// Prepara y abre el formulario de insumo para crear o editar.
  Future<void> openItemForm({InventoryItemModel? item}) async {
    itemForm.reset();
    itemForm.control('name').value = item?.name ?? '';
    itemForm.control('unit').value = item?.unit ?? 'UNIT';
    itemForm.control('currentStock').value = item?.currentStock ?? 0;
    itemForm.control('minStock').value = item?.minStock ?? 0;

    await Get.dialog(InventoryItemFormDialog(controller: this, item: item));
  }

  /// Guarda el insumo en backend y refresca listas para mantener la UI consistente.
  Future<void> saveItem({String? itemId}) async {
    if (itemForm.invalid) {
      itemForm.markAllAsTouched();
      return;
    }

    final Map<String, dynamic> data = {
      'name': itemForm.control('name').value,
      'unit': itemForm.control('unit').value,
      'minStock': itemForm.control('minStock').value,
    };

    if (itemId == null) {
      data['currentStock'] = itemForm.control('currentStock').value;
    }

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          if (itemId == null) {
            await _inventoryRepository.createItem(data);
          } else {
            await _inventoryRepository.updateItem(itemId, data);
          }
          await loadAll();
          Get.back();
          Get.dialog(
            ModalInfo(
              title: 'Operacion Exitosa',
              message: itemId == null
                  ? 'Insumo creado correctamente.'
                  : 'Insumo actualizado correctamente.',
            ),
          );
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: message));
        }
      },
    );
  }

  /// Desactiva un insumo y vuelve a consultar informacion del inventario.
  Future<void> deleteItem(String id) async {
    Get.dialog(
      ModalInfo(
        title: 'Confirmacion',
        message: '¿Está seguro de eliminar este insumo?',
        buttonText: 'Eliminar',
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFB71C1C),
        onClose: () async {
          Get.back();
          Get.showOverlay(
            loadingWidget: const LoadingCharging(),
            asyncFunction: () async {
              try {
                await _inventoryRepository.deleteItem(id);
                await loadAll();
                Get.dialog(
                  const ModalInfo(
                    title: 'Exito',
                    message: 'Insumo eliminado correctamente.',
                  ),
                );
              } catch (e) {
                final message = ExceptionHandler.extractMessage(e);
                Get.dialog(ModalError(message: message));
              }
            },
          );
        },
      ),
    );
  }

  /// Prepara y abre el formulario de movimiento manual de stock.
  Future<void> openManualMovementForm() async {
    movementForm.reset();
    movementForm.control('type').value = 'PURCHASE';
    movementForm.control('quantity').value = 0.0;
    movementForm.control('notes').value = '';
    if (items.isNotEmpty) {
      movementForm.control('inventoryItemId').value = items.first.id;
    }

    await Get.dialog(ManualMovementDialog(controller: this));
  }

  /// Registra un movimiento manual y refresca insumos, alertas e historial.
  Future<void> saveManualMovement() async {
    if (movementForm.invalid) {
      movementForm.markAllAsTouched();
      return;
    }

    final data = {
      'inventoryItemId': movementForm.control('inventoryItemId').value,
      'type': movementForm.control('type').value,
      'quantity': movementForm.control('quantity').value,
      'notes': movementForm.control('notes').value,
    };

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await _inventoryRepository.createManualMovement(data);
          await loadAll();
          Get.back();
          Get.dialog(
            const ModalInfo(
              title: 'Operacion Exitosa',
              message: 'Movimiento de inventario registrado.',
            ),
          );
        } catch (e) {
          final message = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: message));
        }
      },
    );
  }
}
