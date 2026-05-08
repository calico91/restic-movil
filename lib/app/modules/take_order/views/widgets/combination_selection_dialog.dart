import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/product_model.dart';

// Diálogo para seleccionar el plato acompañante de una combinación 2x1 COMBINADO.
// Muestra una lista de productos del mismo grupo con su precio y un preview del costo final.
// Permite agregar un comentario opcional a la combinación.
class CombinationSelectionDialog extends StatefulWidget {
  final ProductModel product;
  final List<ProductModel> siblings;
  final void Function(ProductModel, ProductModel, String?) onConfirm;

  const CombinationSelectionDialog({
    super.key,
    required this.product,
    required this.siblings,
    required this.onConfirm,
  });

  @override
  State<CombinationSelectionDialog> createState() => _CombinationSelectionDialogState();
}

class _CombinationSelectionDialogState extends State<CombinationSelectionDialog> {
  ProductModel? _selected;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Obtiene el precio de un producto (primer precio disponible)
  double _priceOf(ProductModel p) =>
      p.prices?.isNotEmpty == true ? (p.prices!.first.amount ?? 0) : 0;

  // Calcula el precio a cobrar: el máximo entre los dos productos seleccionados
  double get _finalPrice {
    if (_selected == null) return _priceOf(widget.product);
    return _priceOf(widget.product) >= _priceOf(_selected!)
        ? _priceOf(widget.product)
        : _priceOf(_selected!);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('🔗 ', style: TextStyle(fontSize: 20)),
          Expanded(
            child: Text(
              'Combinar: ${widget.product.name ?? ''}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona el plato de acompañamiento:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (widget.siblings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No hay productos disponibles para combinar.',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              )
            else
              // Lista de opciones para combinar
              Flexible(
                child: RadioGroup<ProductModel>(
                  groupValue: _selected,
                  onChanged: (val) => setState(() => _selected = val),
                  child: ListView(
                    shrinkWrap: true,
                    children: widget.siblings.map((sibling) {
                      return RadioListTile<ProductModel>(
                        value: sibling,
                        activeColor: Colors.blue[900],
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          sibling.name ?? '',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '\$${_priceOf(sibling).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            // Preview del costo cuando hay selección
            if (_selected != null) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Text('💰 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.product.name ?? ''} + ${_selected!.name ?? ''}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Precio a cobrar: \$${_finalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Campo de comentario opcional
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comentario (opcional)',
                hintText: 'Ej: Sin picante, término medio...',
                prefixIcon: const Icon(Icons.edit_note, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selected == null
              ? null
              : () {
                  final String? comment = _commentController.text.trim().isEmpty
                      ? null
                      : _commentController.text.trim();
                  widget.onConfirm(widget.product, _selected!, comment);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
