import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';
import 'package:restic_movil/app/data/models/combo_option_model.dart';
import 'package:restic_movil/app/data/models/order_item_model.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';

class ComboSelectionController extends GetxController {
  // Registro estático de tags activos para limpiar al confirmar el pedido
  static final Set<String> _activeTags = {};

  final ProductModel product;
  final PriceModel? price;
  // Retorna el OrderItemModel creado/reemplazado para poder rastrear ediciones
  final OrderItemModel? Function(
    ProductModel,
    PriceModel?,
    int,
    String,
    List<Map<String, String>>,
    double,
    OrderItemModel?,
  ) onConfirm;

  ComboSelectionController({required this.product, this.price, required this.onConfirm});

  // Item del pedido creado en el último submit (para edición posterior)
  OrderItemModel? _editingItem;

  // Lista de selecciones por unidad: índice = unidad, valor = {groupId: {optionId: count}}
  final RxList<Map<String, Map<String, int>>> unitSelections =
      <Map<String, Map<String, int>>>[{}].obs;

  // Índice de la unidad actualmente visible en el diálogo
  final RxInt currentUnit = 0.obs;

  final TextEditingController commentController = TextEditingController();

  // Comentarios por unidad: índice de unidad → texto del comentario
  final Map<int, String> _unitComments = {};

  /* elimina todos los controllers de combos registrados (llamar al confirmar pedido) */
  static void clearAll() {
    for (final String tag in _activeTags.toList()) {
      if (Get.isRegistered<ComboSelectionController>(tag: tag)) {
        Get.delete<ComboSelectionController>(tag: tag, force: true);
      }
    }
    _activeTags.clear();
  }

  /* total de unidades del combo */
  int get quantity => unitSelections.length;

  /* precio total = base × unidades + extras adicionales de todas las unidades */
  double get totalPrice {
    final double base = price?.amount ?? (product.prices?.firstOrNull?.amount ?? 0);
    double extras = 0;
    for (final unitSel in unitSelections) {
      unitSel.forEach((groupId, options) {
        final ComboGroupModel? group =
            product.comboGroups?.where((g) => g.id == groupId).firstOrNull;
        if (group == null) return;
        options.forEach((optionId, count) {
          final option = group.options?.where((o) => o.id == optionId).firstOrNull;
          if (option != null) extras += (option.additionalPrice ?? 0) * count;
        });
      });
    }
    return (base * unitSelections.length) + extras;
  }

  /* precio adicional promedio por unidad (para el modelo de orden) */
  double get additionalPriceOnly {
    double extras = 0;
    for (final unitSel in unitSelections) {
      unitSel.forEach((groupId, options) {
        final ComboGroupModel? group =
            product.comboGroups?.where((g) => g.id == groupId).firstOrNull;
        if (group == null) return;
        options.forEach((optionId, count) {
          final option = group.options?.where((o) => o.id == optionId).firstOrNull;
          if (option != null) extras += (option.additionalPrice ?? 0) * count;
        });
      });
    }
    if (unitSelections.isEmpty) return 0;
    return extras / unitSelections.length;
  }

  /* valida que todas las unidades cumplan los requisitos de grupos obligatorios */
  bool get isValid {
    for (int i = 0; i < unitSelections.length; i++) {
      if (!isValidForUnit(i)) return false;
    }
    return true;
  }

  /* valida una unidad específica contra los grupos obligatorios del combo */
  bool isValidForUnit(int unitIdx) {
    if (product.comboGroups == null || unitIdx >= unitSelections.length) return true;
    for (final ComboGroupModel group in product.comboGroups!) {
      final int total = getGroupTotalCountForUnit(unitIdx, group.id);
      final int min = group.minSelections ?? 0;
      final int max = group.maxSelections ?? 1;
      if (group.required == true && total < min) return false;
      if (total > max) return false;
    }
    return true;
  }

  /* total de opciones seleccionadas en un grupo para una unidad */
  int getGroupTotalCountForUnit(int unitIdx, String? groupId) {
    if (groupId == null || unitIdx >= unitSelections.length) return 0;
    final groupMap = unitSelections[unitIdx][groupId];
    if (groupMap == null) return 0;
    return groupMap.values.fold(0, (sum, c) => sum + c);
  }

  /* cantidad seleccionada de una opción concreta en una unidad */
  int getOptionCountForUnit(int unitIdx, String? groupId, String? optionId) {
    if (groupId == null || optionId == null || unitIdx >= unitSelections.length) return 0;
    return unitSelections[unitIdx][groupId]?[optionId] ?? 0;
  }

  /* agrega una nueva unidad al combo y la activa */
  void addUnit() {
    _unitComments[currentUnit.value] = commentController.text;
    final int newIndex = unitSelections.length;
    unitSelections.add({});
    _unitComments[newIndex] = '';
    switchUnit(newIndex);
  }

  /* elimina la última unidad si hay más de una, ajusta la unidad activa */
  void removeUnit() {
    if (unitSelections.length <= 1) return;
    _unitComments[currentUnit.value] = commentController.text;
    unitSelections.removeLast();
    _unitComments.remove(unitSelections.length);
    if (currentUnit.value >= unitSelections.length) {
      switchUnit(unitSelections.length - 1);
    }
  }

  /* incrementa la cantidad de una opción en la unidad activa */
  void incrementOption(ComboGroupModel group, ComboOptionModel option) {
    _incrementOptionForUnit(currentUnit.value, group, option);
  }

  /* decrementa la cantidad de una opción en la unidad activa */
  void decrementOption(ComboGroupModel group, ComboOptionModel option) {
    _decrementOptionForUnit(currentUnit.value, group, option);
  }

  void _incrementOptionForUnit(int unitIdx, ComboGroupModel group, ComboOptionModel option) {
    if (group.id == null || option.id == null || unitIdx >= unitSelections.length) return;
    final int max = group.maxSelections ?? 1;
    final int currentTotal = getGroupTotalCountForUnit(unitIdx, group.id);
    if (currentTotal >= max) return;

    final Map<String, Map<String, int>> updatedUnit =
        Map<String, Map<String, int>>.from(unitSelections[unitIdx]);
    final Map<String, int> groupMap = Map<String, int>.from(updatedUnit[group.id!] ?? {});
    groupMap[option.id!] = (groupMap[option.id!] ?? 0) + 1;
    updatedUnit[group.id!] = groupMap;
    unitSelections[unitIdx] = updatedUnit;
    unitSelections.refresh();
  }

  void _decrementOptionForUnit(int unitIdx, ComboGroupModel group, ComboOptionModel option) {
    if (group.id == null || option.id == null || unitIdx >= unitSelections.length) return;
    final int count = getOptionCountForUnit(unitIdx, group.id, option.id);
    if (count <= 0) return;

    final Map<String, Map<String, int>> updatedUnit =
        Map<String, Map<String, int>>.from(unitSelections[unitIdx]);
    final Map<String, int> groupMap = Map<String, int>.from(updatedUnit[group.id!] ?? {});
    groupMap[option.id!] = count - 1;
    if (groupMap[option.id!] == 0) groupMap.remove(option.id);
    updatedUnit[group.id!] = groupMap;
    unitSelections[unitIdx] = updatedUnit;
    unitSelections.refresh();
  }

  /* construye la lista de selecciones con unitIndex y llama al callback;
     si ya existe un item previo (_editingItem), lo pasa para que sea reemplazado */
  void submit() {
    if (!isValid) return;

    // Guardar comentario de la unidad actual
    _unitComments[currentUnit.value] = commentController.text;

    // Construir string de comentarios
    final List<MapEntry<int, String>> nonEmptyComments = [];
    for (int i = 0; i < unitSelections.length; i++) {
      final String comment = _unitComments[i]?.trim() ?? '';
      if (comment.isNotEmpty) {
        nonEmptyComments.add(MapEntry(i, comment));
      }
    }

    String commentString;
    if (nonEmptyComments.isEmpty) {
      commentString = '';
    } else if (nonEmptyComments.length == 1) {
      commentString = nonEmptyComments.first.value;
    } else {
      final List<String> parts = nonEmptyComments.map((e) {
        return '[${e.key + 1}] ${e.value}';
      }).toList();
      commentString = 'COMBO_NOTES:${parts.join('|')}';
    }

    final List<Map<String, String>> comboSelectionsList = [];
    for (int unitIdx = 0; unitIdx < unitSelections.length; unitIdx++) {
      unitSelections[unitIdx].forEach((groupId, options) {
        final ComboGroupModel? group =
            product.comboGroups?.where((g) => g.id == groupId).firstOrNull;
        options.forEach((optionId, count) {
          final option = group?.options?.where((o) => o.id == optionId).firstOrNull;
          for (int i = 0; i < count; i++) {
            final Map<String, String> entry = {
              'comboGroupId': groupId,
              'comboOptionId': optionId,
              'unitIndex': unitIdx.toString(),
            };
            if (option?.productName != null) {
              entry['selectedProductName'] = option!.productName!;
            }
            comboSelectionsList.add(entry);
          }
        });
      });
    }
    // Pasar _editingItem para que el callback reemplace el item anterior en el pedido
    _editingItem = onConfirm(
      product,
      price,
      unitSelections.length,
      commentString,
      comboSelectionsList,
      additionalPriceOnly,
      _editingItem,
    );
  }

  /* cambia a una unidad específica, guardando el comentario de la unidad actual antes de cambiar */
  void switchUnit(int newUnit) {
    if (newUnit == currentUnit.value) return;
    if (newUnit < 0 || newUnit >= unitSelections.length) return;
    _unitComments[currentUnit.value] = commentController.text;
    currentUnit.value = newUnit;
    commentController.text = _unitComments[newUnit] ?? '';
    commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: commentController.text.length),
    );
  }

  @override
  void onInit() {
    super.onInit();
    // Registrar el tag activo para permitir limpieza global al confirmar el pedido
    _activeTags.add('combo_${product.id}');
  }

  @override
  void onClose() {
    _activeTags.remove('combo_${product.id}');
    super.onClose();
  }
}
