---
name: nuevo-modelo
description: "Crear modelos de datos Dart con factories fromJson/toJson siguiendo las convenciones del proyecto restic-movil"
---

## Qué hace esta skill

Genera modelos de datos con el patrón `fromJson`/`toJson` que usa el proyecto, incluyendo:
- Campos `final` nullable con `?`
- `factory` constructor `fromJson(Map<String, dynamic>)`
- Método `toJson()` que retorna `Map<String, dynamic>`
- Manejo null-safe de listas anidadas de modelos
- Convención `snake_case` para keys JSON

## Archivo a crear

```
lib/app/data/models/<nombre_modelo>.dart
```

## Template

```dart
import 'package:restic_movil/app/data/models/<modelo_anidado>_model.dart';

class <NombreModelo>Model {
  final String? id;
  final String? name;
  final String? description;
  final bool? active;
  final int? sortOrder;
  final List<<ModeloAnidado>Model>? items;

  <NombreModelo>Model({
    this.id,
    this.name,
    this.description,
    this.active,
    this.sortOrder,
    this.items,
  });

  factory <NombreModelo>Model.fromJson(Map<String, dynamic> json) {
    return <NombreModelo>Model(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      active: json['active'],
      sortOrder: json['sort_order'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => <ModeloAnidado>Model.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
      'sort_order': sortOrder,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}
```

## Convenciones del proyecto

| Concepto | Convención |
|----------|-----------|
| Campos | `final` y nullable (`T?`) — nunca `late` ni required no-nullable |
| Constructor de JSON | `factory` constructor (no named constructor) |
| Nested objects | `(json['key'] as List).map((e) => Model.fromJson(e)).toList()` con null-check |
| Nested null-safe | `list?.map((e) => e.toJson()).toList()` en `toJson()` |
| Keys JSON | `snake_case` (ej. `subcategory_id`, `sort_order`) |
| Nombres de archivo | `snake_case` + sufijo `_model.dart` |
| Nombres de clase | `PascalCase` + sufijo `Model` (ej. `ProductModel`) |
| Ubicación | `lib/app/data/models/` |

## Ejemplos del código real

Tomado de `ProductModel`:

```dart
factory ProductModel.fromJson(Map<String, dynamic> json) {
  return ProductModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    active: json['active'],
    subcategoryId: json['subcategory_id'],
    prices: json['prices'] != null
        ? (json['prices'] as List).map((e) => PriceModel.fromJson(e)).toList()
        : null,
    productType: json['productType'],
    comboGroups: json['combo_groups'] != null
        ? (json['combo_groups'] as List)
            .map((e) => ComboGroupModel.fromJson(e))
            .toList()
        : null,
  );
}
```

## Reglas importantes

1. No usar code generation ni anotaciones — todo manual con `fromJson`/`toJson`
2. Los modelos deben ser clases planas, sin lógica de negocio
3. Los modelos pueden ser request DTOs (crear con sufijo `Request` si aplica, ej. `CreateTransactionRequest`)
4. Siempre agregar `import` de modelos anidados al inicio
5. Probar el modelo después de crearlo con un test unitario simple
