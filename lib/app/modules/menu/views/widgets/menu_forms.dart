import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
import 'package:restic_movil/core/utils/modals/custom_form_dialog.dart';
import 'package:intl/intl.dart';

class CategoryFormDialog extends StatelessWidget {
  final CategoryModel? category;
  final Function(Map<String, dynamic>) onSubmit;

  const CategoryFormDialog({super.key, this.category, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final form = FormGroup({
      'name': FormControl<String>(
        value: category?.name,
        validators: [Validators.required],
      ),
      'description': FormControl<String>(
        value: category?.description ?? '',
        validators: [Validators.required], 
      ),
    });

    return CustomFormDialog(
      title: category == null ? 'Nueva Categoría' : 'Editar Categoría',
      formGroup: form,
      onSave: () => onSubmit(form.value as Map<String, dynamic>),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReactiveTextField<String>(
            formControlName: 'name',
            decoration: const InputDecoration(
              labelText: 'Nombre de la Categoría',
              border: OutlineInputBorder(),
            ),
            validationMessages: {'required': (error) => 'Requerido'},
          ),
          const SizedBox(height: 16),
          ReactiveTextField<String>(
            formControlName: 'description',
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            validationMessages: {'required': (error) => 'Requerido'},
          ),
        ],
      ),
    );
  }
}

class SubcategoryFormDialog extends StatelessWidget {
  final String categoryId;
  final SubcategoryModel? subcategory;
  final Function(Map<String, dynamic>) onSubmit;

  const SubcategoryFormDialog({
    super.key,
    required this.categoryId,
    this.subcategory,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final form = FormGroup({
      'name': FormControl<String>(
        value: subcategory?.name,
        validators: [Validators.required],
      ),
      'description': FormControl<String>(
        value: subcategory?.description ?? '',
      ), // ❌ no es requerido
    });

    return CustomFormDialog(
      title: subcategory == null ? 'Nueva Subcategoría' : 'Editar Subcategoría',
      formGroup: form,
      onSave: () {
        final data = Map<String, dynamic>.from(form.value);
        data['categoryId'] = categoryId; // Siempre enviar categoryId
        onSubmit(data);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReactiveTextField<String>(
            formControlName: 'name',
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            validationMessages: {'required': (error) => 'Requerido'},
          ),
          const SizedBox(height: 16),
          ReactiveTextField<String>(
            formControlName: 'description',
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class ProductFormDialog extends StatelessWidget {
  final String categoryId;
  final String subcategoryId;
  final ProductModel? product;
  final Function(Map<String, dynamic>) onSubmit;

  const ProductFormDialog({
    super.key,
    required this.categoryId,
    required this.subcategoryId,
    this.product,
    required this.onSubmit,
  });

  FormGroup _buildForm() {
    final String initialType = product?.productType ?? 'SIMPLE';
    final List<PriceModel?> initialPrices =
        product?.prices?.isNotEmpty == true
            ? List<PriceModel?>.from(product!.prices!)
            : [null]; // un precio vacío para productos nuevos

    return FormGroup({
      'name': FormControl<String>(
        value: product?.name,
        validators: [Validators.required],
      ),
      'description': FormControl<String>(value: product?.description ?? ''),
      'productType': FormControl<String>(
        value: initialType,
        validators: [Validators.required],
      ),
      'requires_recipe': FormControl<bool>(
        value: product?.requiresRecipe ?? false,
      ),
      'prices': FormArray(
        initialPrices.map((p) {
          final currentPrice = p?.amount;
          final String? priceStr = currentPrice != null
              ? NumberFormat.decimalPattern('es_CO').format(currentPrice)
              : null;
          return FormGroup({
            'amount': FormControl<String>(
              value: priceStr,
              validators: [
                Validators.required,
                Validators.pattern(RegExp(r'^[0-9.]+$')),
              ],
            ),
            'size_label': FormControl<String>(value: p?.sizeLabel ?? ''),
          });
        }).toList(),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = _buildForm();

    return CustomFormDialog(
      title: product == null ? 'Nuevo Producto' : 'Editar Producto',
      formGroup: form,
      onSave: () {
        final data = Map<String, dynamic>.from(form.value);
        final String productType = data['productType'];

        // Mapear el array de precios
        final List<Map<String, dynamic>> pricesArray = (data['prices'] as List)
            .map((p) {
              final priceValue = p['amount'] as String;
              final double amount =
                  double.tryParse(
                    priceValue.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0.0;

              // Usar inicio del día actual para evitar problemas de desfase de reloj con el servidor
              final DateTime startOfDay = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              );
              final Map<String, dynamic> priceMap = {
                "amount": amount,
                "start_date": DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startOfDay),
                "end_date": null,
              };

              if (productType == 'VARIABLE' &&
                  p['size_label'] != null &&
                  p['size_label'].toString().isNotEmpty) {
                priceMap['size_label'] = p['size_label'];
              }

              return priceMap;
            })
            .toList();

        final formattedResult = {
          "name": data['name'],
          "description": data['description'],
          "productType": productType,
          "category_id": categoryId,
          "subcategory_id": subcategoryId,
          "requires_recipe": data['requires_recipe'] ?? false,
          "prices": pricesArray,
          "combo_groups": null,
        };

        onSubmit(formattedResult);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReactiveTextField<String>(
            formControlName: 'name',
            decoration: const InputDecoration(
              labelText: 'Nombre del Producto',
              border: OutlineInputBorder(),
            ),
            validationMessages: {'required': (error) => 'Requerido'},
          ),
          const SizedBox(height: 16),
          ReactiveTextField<String>(
            formControlName: 'description',
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ReactiveDropdownField<String>(
            formControlName: 'productType',
            decoration: const InputDecoration(
              labelText: 'Tipo de Producto',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'SIMPLE', child: Text('Simple')),
              DropdownMenuItem(value: 'COMBO', child: Text('Combo')),
              DropdownMenuItem(value: 'VARIABLE', child: Text('Variable (por tamaño)')),
              DropdownMenuItem(value: 'COMBINADO', child: Text('Combinado 2x1')),
            ],
            onChanged: (control) {
              final pricesControl = form.control('prices') as FormArray;
              final String type = control.value ?? 'SIMPLE';
              // Para tipos con un solo precio, conservar solo el primero
              if (type != 'VARIABLE' && pricesControl.controls.length > 1) {
                while (pricesControl.controls.length > 1) {
                  pricesControl.removeAt(pricesControl.controls.length - 1);
                }
              }
            },
          ),
          const SizedBox(height: 16),
          ReactiveSwitchListTile(
            formControlName: 'requires_recipe',
            title: const Text('Requiere receta de inventario'),
            subtitle: const Text('Activalo para descontar insumos automaticamente al pagar.'),
          ),
          const SizedBox(height: 16),
          ReactiveValueListenableBuilder<String>(
            formControlName: 'productType',
            builder: (context, control, child) {
              final bool isVariable = control.value == 'VARIABLE';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVariable ? 'Precios y Tamaños' : 'Precio',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ReactiveFormArray(
                    formArrayName: 'prices',
                    builder: (context, formArray, child) {
                      return Column(
                        children: [
                          for (int i = 0; i < formArray.controls.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isVariable) ...[
                                    Expanded(
                                      flex: 3,
                                      child: ReactiveTextField<String>(
                                        formControlName: '$i.size_label',
                                        decoration: const InputDecoration(
                                          labelText: 'Tamaño (ej: 12oz)',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    flex: 4,
                                    child: ReactiveTextField<String>(
                                      formControlName: '$i.amount',
                                      validationMessages: {
                                        'required': (error) => 'Requerido',
                                        'pattern': (error) => 'Solo números',
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Precio',
                                        border: OutlineInputBorder(),
                                        prefixText: '\$ ',
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        ThousandsSeparatorInputFormatter(),
                                      ],
                                    ),
                                  ),
                                  if (isVariable &&
                                      formArray.controls.length > 1)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        formArray.removeAt(i);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          if (isVariable)
                            TextButton.icon(
                              onPressed: () {
                                formArray.add(
                                  FormGroup({
                                    'amount': FormControl<String>(
                                      validators: [
                                        Validators.required,
                                        Validators.pattern(
                                          RegExp(r'^[0-9.]+$'),
                                        ),
                                      ],
                                    ),
                                    'size_label': FormControl<String>(
                                      value: '',
                                    ),
                                  }),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar Precio'),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
