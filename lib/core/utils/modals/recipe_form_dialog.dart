import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/inventory_item_model.dart';
import 'package:restic_movil/app/data/models/price_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';
import 'package:restic_movil/app/data/models/product_recipe_model.dart';

class RecipeFormDialog extends StatefulWidget {
  final ProductModel product;
  final List<InventoryItemModel> inventoryItems;
  final List<ProductRecipeModel> existingRecipes;
  final Future<bool> Function(String? priceVariantId, List<Map<String, dynamic>> ingredients) onSave;
  final Future<bool> Function(String? priceVariantId) onDelete;

  const RecipeFormDialog({
    super.key,
    required this.product,
    required this.inventoryItems,
    required this.existingRecipes,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<RecipeFormDialog> createState() => _RecipeFormDialogState();
}

class _RecipeFormDialogState extends State<RecipeFormDialog> {
  final Map<String, List<_RecipeRow>> _rowsByVariant = {};
  String _selectedVariantKey = 'base';

  @override
  void initState() {
    super.initState();
    _initRows();
  }

  void _initRows() {
    if (widget.product.productType == 'VARIABLE' && (widget.product.prices?.isNotEmpty ?? false)) {
      for (final PriceModel price in widget.product.prices!) {
        final String key = price.id ?? 'base';
        final ProductRecipeModel? existing = widget.existingRecipes.firstWhereOrNull(
          (recipe) => recipe.priceVariantId == price.id,
        );
        _rowsByVariant[key] = _fromExisting(existing);
      }
      _selectedVariantKey = widget.product.prices!.first.id ?? 'base';
      return;
    }

    final ProductRecipeModel? existing = widget.existingRecipes.firstWhereOrNull(
      (recipe) => recipe.priceVariantId == null,
    );
    _rowsByVariant['base'] = _fromExisting(existing);
  }

  List<_RecipeRow> _fromExisting(ProductRecipeModel? existing) {
    if (existing == null || existing.ingredients == null || existing.ingredients!.isEmpty) {
      return [_RecipeRow()];
    }

    return existing.ingredients!
        .map((ingredient) => _RecipeRow(
              inventoryItemId: ingredient.inventoryItemId,
              quantity: ingredient.quantity?.toString() ?? '',
            ))
        .toList();
  }

  List<_RecipeRow> get _currentRows {
    return _rowsByVariant.putIfAbsent(_selectedVariantKey, () => [_RecipeRow()]);
  }

  bool _hasRecipeForCurrentVariant() {
    final String? variantId = widget.product.productType == 'VARIABLE'
        ? (_selectedVariantKey == 'base' ? null : _selectedVariantKey)
        : null;

    return widget.existingRecipes.any((recipe) => recipe.priceVariantId == variantId);
  }

  @override
  void dispose() {
    for (final rows in _rowsByVariant.values) {
      for (final row in rows) {
        row.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Receta: ${widget.product.name ?? ''}'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.product.productType == 'VARIABLE' && (widget.product.prices?.isNotEmpty ?? false))
                DropdownButtonFormField<String>(
                  initialValue: _selectedVariantKey,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Variante de precio',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.product.prices!
                      .map(
                        (price) => DropdownMenuItem(
                          value: price.id,
                          child: Text(
                            price.sizeLabel ?? 'Variante sin etiqueta',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedVariantKey = value;
                    });
                  },
                ),
              const SizedBox(height: 12),
              KeyedSubtree(
                key: ValueKey('variant_${_selectedVariantKey}_rows'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(_currentRows.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: DropdownButtonFormField<String>(
                                key: ValueKey('${_selectedVariantKey}_$index'),
                                initialValue: _currentRows[index].inventoryItemId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Insumo',
                                  border: OutlineInputBorder(),
                                ),
                                items: widget.inventoryItems
                                    .where((item) => item.id != null)
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item.id,
                                        child: Text(
                                          item.name ?? '-',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _currentRows[index].inventoryItemId = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _currentRows[index].quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Cantidad',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _currentRows.length <= 1
                                  ? null
                                  : () {
                                      setState(() {
                                        _currentRows[index].dispose();
                                        _currentRows.removeAt(index);
                                      });
                                    },
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentRows.add(_RecipeRow());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar ingrediente'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        if (_hasRecipeForCurrentVariant())
          OutlinedButton.icon(
            onPressed: () async {
              final String? variantId = widget.product.productType == 'VARIABLE'
                  ? (_selectedVariantKey == 'base' ? null : _selectedVariantKey)
                  : null;
              final bool deleted = await widget.onDelete(variantId);
              if (deleted) {
                Get.back(result: 'deleted');
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar receta'),
          ),
        ElevatedButton(
          onPressed: () async {
            final List<Map<String, dynamic>> payload = _currentRows
                .where((row) => row.inventoryItemId != null && row.quantityController.text.trim().isNotEmpty)
                .map(
                  (row) => {
                    'inventoryItemId': row.inventoryItemId,
                    'quantity': double.tryParse(row.quantityController.text.replaceAll(',', '.')) ?? 0,
                  },
                )
                .where((row) => (row['quantity'] as double) > 0)
                .toList();

            if (payload.isEmpty) {
              Get.snackbar('Validacion', 'Debe agregar al menos un ingrediente valido.');
              return;
            }

            final String? variantId = widget.product.productType == 'VARIABLE' ? _selectedVariantKey : null;
            final bool saved = await widget.onSave(
              variantId == 'base' ? null : variantId,
              payload,
            );

            if (saved) {
              Get.back(result: 'saved');
            }
          },
          child: const Text('Guardar receta'),
        ),
      ],
    );
  }
}

class _RecipeRow {
  String? inventoryItemId;
  final TextEditingController quantityController;

  _RecipeRow({
    this.inventoryItemId,
    String quantity = '',
  }) : quantityController = TextEditingController(text: quantity);

  void dispose() {
    quantityController.dispose();
  }
}
