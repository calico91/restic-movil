import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';
import 'package:restic_movil/app/data/models/combo_option_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';

class ComboSelectionController extends GetxController {
  final ProductModel product;
  final Function(ProductModel, int, String, List<Map<String, String>>, double)
  onConfirm;

  ComboSelectionController({required this.product, required this.onConfirm});

  // State
  final RxInt quantity = 1.obs;
  final RxMap<String, Map<String, int>> selections =
      <String, Map<String, int>>{}.obs;
  final commentController = TextEditingController();

  // Computed Properties
  double get totalPrice {
    double base = product.price?.amount ?? 0;
    double extras = 0;

    selections.forEach((groupId, options) {
      final group = product.comboGroups?.firstWhere((g) => g.id == groupId);
      if (group == null) return;

      options.forEach((optionId, count) {
        final option = group.options?.firstWhere((o) => o.id == optionId);
        if (option != null) {
          extras += (option.additionalPrice ?? 0) * count;
        }
      });
    });

    return (base * quantity.value) + extras;
  }

  double get additionalPriceOnly {
    double extras = 0;
    selections.forEach((groupId, options) {
      final group = product.comboGroups?.firstWhere((g) => g.id == groupId);
      if (group == null) return;
      options.forEach((optionId, count) {
        final option = group.options?.firstWhere((o) => o.id == optionId);
        if (option != null) {
          extras += (option.additionalPrice ?? 0) * count;
        }
      });
    });

    if (quantity.value == 0) return 0;
    return extras / quantity.value;
  }

  bool get isValid {
    if (product.comboGroups == null) return true;

    for (var group in product.comboGroups!) {
      final totalSelected = getGroupTotalCount(group.id);
      final min = getAdjustedLimit(group.minSelections ?? 0);
      // Validar con la cantidad seleccionada en el input, ignorando el json
      final max = quantity.value;

      if (group.required == true) {
        if (totalSelected < min) return false;
      }
      if (totalSelected > max) return false;
    }
    return true;
  }

  // Methods
  int getAdjustedLimit(int limit) {
    return limit * quantity.value;
  }

  int getGroupTotalCount(String? groupId) {
    if (groupId == null) return 0;
    final groupSelections = selections[groupId];
    if (groupSelections == null) return 0;
    return groupSelections.values.fold(0, (sum, count) => sum + count);
  }

  int getOptionCount(String? groupId, String? optionId) {
    if (groupId == null || optionId == null) return 0;
    return selections[groupId]?[optionId] ?? 0;
  }

  void updateQuantity(int delta) {
    final newQuantity = quantity.value + delta;
    if (newQuantity > 0) {
      quantity.value = newQuantity;
    }
  }

  void incrementOption(ComboGroupModel group, ComboOptionModel option) {
    if (group.id == null || option.id == null) return;

    final currentGroupTotal = getGroupTotalCount(group.id);
    // Validar con la cantidad seleccionada en el input, ignorando el json
    final max = quantity.value;

    if (currentGroupTotal < max) {
      final Map<String, int> groupMap = Map<String, int>.from(
        selections[group.id] ?? {},
      );
      groupMap[option.id!] = (groupMap[option.id!] ?? 0) + 1;
      selections[group.id!] = groupMap;
    }
  }

  void decrementOption(ComboGroupModel group, ComboOptionModel option) {
    if (group.id == null || option.id == null) return;

    final count = getOptionCount(group.id, option.id);
    if (count > 0) {
      final Map<String, int> groupMap = Map<String, int>.from(
        selections[group.id] ?? {},
      );
      groupMap[option.id!] = count - 1;
      if (groupMap[option.id!] == 0) {
        groupMap.remove(option.id);
      }
      selections[group.id!] = groupMap;
    }
  }

  void submit() {
    if (!isValid) return;

    // Build the list of selections for JSON
    List<Map<String, String>> comboSelectionsList = [];
    selections.forEach((groupId, options) {
      options.forEach((optionId, count) {
        for (int i = 0; i < count; i++) {
          comboSelectionsList.add({
            "comboGroupId": groupId,
            "comboOptionId": optionId,
          });
        }
      });
    });

    onConfirm(
      product,
      quantity.value,
      commentController.text,
      comboSelectionsList,
      additionalPriceOnly,
    );
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
