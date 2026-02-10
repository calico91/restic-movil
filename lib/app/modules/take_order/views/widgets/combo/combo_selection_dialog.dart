import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/combo_group_model.dart';
import 'package:restic_movil/app/data/models/combo_option_model.dart';
import 'package:restic_movil/app/data/models/product_model.dart';

class ComboSelectionDialog extends StatefulWidget {
  final ProductModel product;
  final Function(ProductModel, int, String) onConfirm;

  const ComboSelectionDialog({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  State<ComboSelectionDialog> createState() => _ComboSelectionDialogState();
}

class _ComboSelectionDialogState extends State<ComboSelectionDialog> {
  // Map<groupId, Map<optionId, quantity>>
  final Map<String, Map<String, int>> _selectionCounts = {};

  // Cache de opcion por id para acceso rapido en calculos
  final Map<String, ComboOptionModel> _optionCache = {};

  final TextEditingController _commentController = TextEditingController();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Llenar cache
    widget.product.comboGroups?.forEach((group) {
      group.options?.forEach((option) {
        if (option.id != null) {
          _optionCache[option.id!] = option;
        }
      });
    });
  }

  /*  Logica de Precio Total*/
  double get _totalPrice {
    double base = widget.product.price?.amount ?? 0;
    double extras = 0;

    _selectionCounts.forEach((groupId, optionsMap) {
      optionsMap.forEach((optionId, count) {
        if (count > 0 && _optionCache.containsKey(optionId)) {
          extras += (_optionCache[optionId]?.additionalPrice ?? 0) * count;
        }
      });
    });

    return (base * _quantity) + extras;
  }

  /*  Validacion de Selecciones*/
  bool get _isValid {
    if (widget.product.comboGroups == null) return true;

    for (var group in widget.product.comboGroups!) {
      if (group.required == true) {
        final selectedCount = _getGroupTotalCount(group.id);
        final min = _getAdjustedLimit(group.minSelections ?? 0);

        if (selectedCount < min) return false;
      }

      // Validar maximos tambien, por si reduce la cantidad
      final selectedCount = _getGroupTotalCount(group.id);
      final max = _getAdjustedLimit(group.maxSelections ?? 1);
      if (selectedCount > max) return false;
    }
    return true;
  }

  /*  Dado que la cantidad global del combo afecta directamente los límites de selección de cada grupo (por ejemplo, si el combo es para 2 personas, y un grupo requiere seleccionar 1 opción por persona, entonces el mínimo sería 2), esta función ajusta los límites de selección multiplicándolos por la cantidad actual del combo. Esto asegura que las restricciones de selección se apliquen correctamente en función de cuántos combos se están ordenando.
*/
  int _getAdjustedLimit(int limit) {
    return limit * _quantity;
  }

  /*  Funciones de Incremento/Decremento y Cálculo de Totales*/
  int _getGroupTotalCount(String? groupId) {
    if (groupId == null) return 0;
    final optionsMap = _selectionCounts[groupId];
    if (optionsMap == null) return 0;

    return optionsMap.values.fold(0, (sum, count) => sum + count);
  }

  /* Esta función obtiene la cantidad seleccionada para una opción específica dentro de un grupo. Si no se ha seleccionado nada, devuelve 0. Es fundamental para mostrar la cantidad actual en la interfaz y para calcular el precio total correctamente.*/
  int _getOptionCount(String? groupId, String? optionId) {
    if (groupId == null || optionId == null) return 0;
    return _selectionCounts[groupId]?[optionId] ?? 0;
  }

  /*  Funciones de Incremento/Decremento y Cálculo de Totales*/
  void _incrementOption(ComboGroupModel group, ComboOptionModel option) {
    if (group.id == null || option.id == null) return;

    final currentGroupTotal = _getGroupTotalCount(group.id);
    final max = _getAdjustedLimit(group.maxSelections ?? 1);

    if (currentGroupTotal >= max) return; // Limite alcanzado

    setState(() {
      final optionsMap = _selectionCounts[group.id!] ?? {};
      final currentCount = optionsMap[option.id!] ?? 0;
      optionsMap[option.id!] = currentCount + 1;
      _selectionCounts[group.id!] = optionsMap;
    });
  }

  /* Esta función decrementa la cantidad seleccionada para una opción específica dentro de un grupo. Verifica que la cantidad actual sea mayor a 0 antes de decrementar para evitar valores negativos. Si la cantidad llega a 0, se elimina la entrada del mapa para mantenerlo limpio.*/
  void _decrementOption(ComboGroupModel group, ComboOptionModel option) {
    if (group.id == null || option.id == null) return;

    final currentCount = _getOptionCount(group.id, option.id);
    if (currentCount <= 0) return;

    setState(() {
      final optionsMap = _selectionCounts[group.id!] ?? {};
      optionsMap[option.id!] = currentCount - 1;

      if (optionsMap[option.id!] == 0) {
        optionsMap.remove(option.id);
      }
      _selectionCounts[group.id!] = optionsMap;
    });
  }

  /* Esta función actualiza la cantidad global de combos. Asegura que la cantidad no sea menor a 1. Al cambiar la cantidad, también se verifica la validez de las selecciones, ya que los límites de selección pueden cambiar en función de la cantidad. Si la nueva cantidad hace que las selecciones actuales sean inválidas (por ejemplo, si reduce la cantidad y ahora no cumple con el mínimo requerido), el botón de confirmación se deshabilitará automáticamente debido a la lógica en el getter _isValid.*/
  void _updateQuantity(int delta) {
    final newQuantity = _quantity + delta;
    if (newQuantity < 1) return;
    setState(() {
      _quantity = newQuantity;
    });
  }

  /* Esta función se llama cuando el usuario confirma su selección. Primero verifica si las selecciones son válidas. Luego, construye una cadena de texto que describe las selecciones realizadas por el usuario, organizadas por grupo. Si el usuario ha agregado comentarios adicionales, también se incluyen en la descripción. Finalmente, llama a la función onConfirm proporcionada por el widget padre, pasando el producto seleccionado, la cantidad y la descripción de las selecciones, y cierra el diálogo.*/
  void _submit() {
    if (!_isValid) return;

    // Construir string de observaciones con las selecciones
    final buffer = StringBuffer();

    // Agregar selecciones organizadas por grupo
    widget.product.comboGroups?.forEach((group) {
      final optionsMap = _selectionCounts[group.id];
      if (optionsMap != null && optionsMap.isNotEmpty) {
        final List<String> parts = [];
        optionsMap.forEach((optionId, count) {
          if (count > 0 && _optionCache.containsKey(optionId)) {
            final name = _optionCache[optionId]?.productName ?? '';
            if (count > 1) {
              parts.add('$count x $name');
            } else {
              parts.add(name);
            }
          }
        });
        if (parts.isNotEmpty) {
          buffer.writeln('${group.name}: ${parts.join(', ')}');
        }
      }
    });

    if (_commentController.text.isNotEmpty) {
      buffer.writeln('Nota: ${_commentController.text}');
    }

    widget.onConfirm(widget.product, _quantity, buffer.toString().trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product.name ?? 'Arma tu Combo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.description != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  widget.product.description!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

            // Selector de Cantidad Global
            _buildQuantitySelector(),
            const Divider(),

            ...?widget.product.comboGroups?.map(
              (group) => _buildGroupSection(group),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentarios adicionales',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isValid ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isValid ? Colors.blue[900] : Colors.grey,
            foregroundColor: Colors.white,
          ),
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Cantidad de Combos:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.blue),
                onPressed: () => _updateQuantity(-1),
              ),
              Text(
                '$_quantity',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () => _updateQuantity(1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSection(ComboGroupModel group) {
    // Calculos de totales
    final currentCount = _getGroupTotalCount(group.id);
    final min = _getAdjustedLimit(group.minSelections ?? 0);
    final max = _getAdjustedLimit(group.maxSelections ?? 1);

    final options = group.options ?? [];
    options.sort(
      (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    group.name ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (group.required == true && currentCount < min)
                    const Text(' *', style: TextStyle(color: Colors.red)),
                ],
              ),
              Text(
                'Seleccionados: $currentCount / $max (Mínimo $min)',
                style: TextStyle(
                  fontSize: 12,
                  color: currentCount < min ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        ...options.map(
          (option) => _buildOptionRow(group, option, max, currentCount),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildOptionRow(
    ComboGroupModel group,
    ComboOptionModel option,
    int maxTotal,
    int currentTotal,
  ) {
    final price = option.additionalPrice ?? 0;
    final count = _getOptionCount(group.id, option.id);

    // Deshabilitar boton + si alcanzamos el maximo del grupo
    final canIncrement = currentTotal < maxTotal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(option.productName ?? ''),
                if (price > 0)
                  Text(
                    '+ \$${price.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            height: 36,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                  onPressed: count > 0
                      ? () => _decrementOption(group, option)
                      : null,
                ),
                Text(
                  '$count',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                  onPressed: canIncrement
                      ? () => _incrementOption(group, option)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
