import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/app/data/models/category_model.dart';
import 'package:restic_movil/core/utils/formatters/thousands_separator_input_formatter.dart';
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
        validators: [Validators.required], // ✅ @NotBlank
      ),
    });

    return AlertDialog(
      title: Text(category == null ? 'Nueva Categoría' : 'Editar Categoría'),
      content: ReactiveForm(
        formGroup: form,
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
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ReactiveForm(
          formGroup: form,
          child: ReactiveFormConsumer(
            builder: (context, formGroup, child) {
              return ElevatedButton(
                onPressed: formGroup.valid
                    ? () {
                        Get.back();
                        onSubmit(formGroup.value as Map<String, dynamic>);
                      }
                    : null,
                child: const Text('Guardar'),
              );
            },
          ),
        ),
      ],
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

    return AlertDialog(
      title: Text(
        subcategory == null ? 'Nueva Subcategoría' : 'Editar Subcategoría',
      ),
      content: ReactiveForm(
        formGroup: form,
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
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ReactiveForm(
          formGroup: form,
          child: ReactiveFormConsumer(
            builder: (context, formGroup, child) {
              return ElevatedButton(
                onPressed: formGroup.valid
                    ? () {
                        Get.back();
                        final data = Map<String, dynamic>.from(formGroup.value);
                        data['categoryId'] =
                            categoryId; // Siempre enviar categoryId
                        onSubmit(data);
                      }
                    : null,
                child: const Text('Guardar'),
              );
            },
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final currentPrice = product?.price?.amount;
    final String? priceStr = currentPrice != null 
        ? NumberFormat.decimalPattern('es_CO').format(currentPrice)
        : null;

    final form = FormGroup({
      'name': FormControl<String>(
        value: product?.name,
        validators: [Validators.required],
      ),
      'description': FormControl<String>(value: product?.description ?? ''),
      'price': FormControl<String>(
        value: priceStr,
        validators: [
          Validators.required,
          Validators.pattern(RegExp(r'^[0-9.]+$')),
        ],
      ),
    });

    return AlertDialog(
      title: Text(product == null ? 'Nuevo Producto' : 'Editar Producto'),
      content: SingleChildScrollView(
        child: ReactiveForm(
          formGroup: form,
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
              ReactiveTextField<String>(
                formControlName: 'price',
                validationMessages: {
                  'required': (error) => 'Requerido',
                  'pattern': (error) => 'Solo se permiten números',
                },
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ReactiveForm(
          formGroup: form,
          child: ReactiveFormConsumer(
            builder: (context, formGroup, child) {
              return ElevatedButton(
                onPressed: formGroup.valid
                    ? () {
                        Get.back();
                        final data = Map<String, dynamic>.from(formGroup.value);

                        // Ajustar el objeto de salida según requirements de la API
                        final priceValue = data['price'] as String;
                        final double amount = double.tryParse(priceValue.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                        data.remove('price');

                        final formattedResult = {
                          "name": data['name'],
                          "description": data['description'],
                          "productType": "SIMPLE",
                          "category_id": categoryId,
                          "subcategory_id": subcategoryId,
                          "prices": [
                            {
                              "amount": amount,
                              "start_date": DateFormat(
                                "yyyy-MM-dd'T'HH:mm:ss",
                              ).format(DateTime.now()), // Vigente desde ya
                              "end_date": null,
                            },
                          ],
                          "combo_groups": null,
                        };

                        onSubmit(formattedResult);
                      }
                    : null,
                child: const Text('Guardar'),
              );
            },
          ),
        ),
      ],
    );
  }
}
