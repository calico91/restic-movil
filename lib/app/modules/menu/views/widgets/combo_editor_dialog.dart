import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';

class ComboEditorDialog extends StatefulWidget {
  final ProductModel combo;
  final List<ProductModel> simpleProducts;
  final Future<void> Function(String groupId, String productId) onAddOption;
  final Future<void> Function(String optionId) onRemoveOption;
  final Future<void> Function(String optionId) onToggleOption;
  final Future<ProductModel> Function() onRefresh;

  const ComboEditorDialog({
    super.key,
    required this.combo,
    required this.simpleProducts,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.onToggleOption,
    required this.onRefresh,
  });

  @override
  State<ComboEditorDialog> createState() => _ComboEditorDialogState();
}

class _ComboEditorDialogState extends State<ComboEditorDialog> {
  late ProductModel _combo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _combo = widget.combo;
  }

  List<ProductModel> _availableProducts() {
    final used = <String>{};
    for (final group in _combo.comboGroups ?? []) {
      for (final opt in group.options ?? []) {
        if (opt.productId != null) used.add(opt.productId!);
      }
    }
    return widget.simpleProducts
        .where((p) => p.id != null && !used.contains(p.id))
        .toList();
  }

  Future<void> _addOption(String groupId) async {
    final available = _availableProducts();
    final selected = await showDialog<ProductModel>(
      context: context,
      builder: (context) => _ProductPickerDialog(
        products: available,
      ),
    );

    if (selected == null || selected.id == null) return;

    setState(() => _isLoading = true);
    try {
      await widget.onAddOption(groupId, selected.id!);
      _combo = await widget.onRefresh();
      setState(() {});
      Get.dialog(ModalInfo(title: 'Éxito', message: 'Opción agregada correctamente'));
    } catch (e) {
      final message = ExceptionHandler.extractMessage(e);
      Get.dialog(ModalError(message: message));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeOption(String optionId, String productName, bool isActive) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text(isActive
            ? '¿Desactivar "$productName"? Ya no aparecera en nuevos pedidos.'
            : '¿Reactivar "$productName"? Volvera a aparecer en pedidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : Colors.green,
            ),
            child: Text(
              isActive ? 'Desactivar' : 'Reactivar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      if (isActive) {
        await widget.onRemoveOption(optionId);
        _combo = await widget.onRefresh();
        setState(() {});
        Get.dialog(ModalInfo(title: 'Éxito', message: 'Opción desactivada correctamente'));
      } else {
        await widget.onToggleOption(optionId);
        _combo = await widget.onRefresh();
        setState(() {});
        Get.dialog(ModalInfo(title: 'Éxito', message: 'Opción reactivada correctamente'));
      }
    } catch (e) {
      final message = ExceptionHandler.extractMessage(e);
      Get.dialog(ModalError(message: message));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _combo.comboGroups ?? [];

    return Stack(
      children: [
        AlertDialog(
          backgroundColor: const Color(0xFFF5F6FA),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Administrar "${_combo.name ?? 'Combo'}"',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: groups.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Este combo no tiene grupos definidos.'),
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: groups.map((group) {
                        return _GroupSection(
                          group: group,
                          onAddOption: () => _addOption(group.id!),
                          onToggleOption: (optionId, productName, isActive) =>
                              _removeOption(optionId, productName, isActive),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: LoadingCharging()),
          ),
      ],
    );
  }
}

class _GroupSection extends StatelessWidget {
  final ComboGroupModel group;
  final VoidCallback onAddOption;
  final Future<void> Function(String optionId, String productName, bool isActive) onToggleOption;

  const _GroupSection({
    required this.group,
    required this.onAddOption,
    required this.onToggleOption,
  });

  @override
  Widget build(BuildContext context) {
    final options = group.options ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name ?? 'Grupo',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'Min: ${group.minSelections} / Max: ${group.maxSelections}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onAddOption,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D47A1)),
              ),
            ],
          ),
          if (options.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Sin opciones', style: TextStyle(color: Colors.grey)),
            )
          else
            ...options.map((opt) {
              final isActive = opt.available != false;
              return Opacity(
                opacity: isActive ? 1.0 : 0.5,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    opt.productName ?? 'Sin nombre',
                    style: TextStyle(
                      decoration: isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: !isActive
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Inactiva',
                            style: TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: Icon(
                      isActive ? Icons.remove_circle_outline : Icons.restore,
                      color: isActive ? Colors.red : Colors.green,
                      size: 20,
                    ),
                    onPressed: () => onToggleOption(
                      opt.id!,
                      opt.productName ?? '',
                      isActive,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ProductPickerDialog extends StatelessWidget {
  final List<ProductModel> products;

  const _ProductPickerDialog({required this.products});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF5F6FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Seleccionar producto',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D47A1),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: products.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No hay productos disponibles para agregar.'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product.name ?? 'Sin nombre'),
                    subtitle: product.description != null ? Text(product.description!) : null,
                    trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF0D47A1)),
                    onTap: () => Navigator.pop(context, product),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
