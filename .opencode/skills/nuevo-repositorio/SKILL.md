---
name: nuevo-repositorio
description: "Crear repositorios para la capa de datos usando BaseHttpClient, UrlPaths y modelos del proyecto restic-movil"
---

## Qué hace esta skill

Crea un repositorio siguiendo el patrón establecido en el proyecto:
- Inyección de `BaseHttpClient` por constructor
- Métodos que retornan `Future<T>` (modelo, `List<modelo>`, o `void`)
- Uso de constantes de `UrlPaths` para endpoints
- Mapeo de respuestas JSON a modelos con `fromJson`
- Construcción inline de paths con IDs dinámicos
- Manejo de errores estándar (delegado a `BaseHttpClient`)

## Archivo a crear

```
lib/app/data/repositories/<nombre_repositorio>_repository.dart
```

## Template

```dart
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/http/url_paths.dart';
import 'package:restic_movil/app/data/models/<modelo>_model.dart';

class <NombreRepositorio>Repository {
  final BaseHttpClient _client;

  <NombreRepositorio>Repository(this._client);

  /// Obtener todos los registros
  Future<List<<Modelo>Model>> getAll() async {
    final response = await _client.get(UrlPaths.get<NombreModelos>);
    return (response as List)
        .map((e) => <Modelo>Model.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtener registro por ID
  Future<<Modelo>Model> getById(String id) async {
    final response = await _client.get(
      '${UrlPaths.get<NombreModelo>ById}/$id',
    );
    return <Modelo>Model.fromJson(response as Map<String, dynamic>);
  }

  /// Crear un nuevo registro
  Future<<Modelo>Model> create(Map<String, dynamic> data) async {
    final response = await _client.post(UrlPaths.create<NombreModelo>, body: data);
    return <Modelo>Model.fromJson(response as Map<String, dynamic>);
  }

  /// Actualizar un registro existente
  Future<<Modelo>Model> update(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      '${UrlPaths.update<NombreModelo>}/$id',
      body: data,
    );
    return <Modelo>Model.fromJson(response as Map<String, dynamic>);
  }

  /// Eliminar un registro
  Future<void> delete(String id) async {
    await _client.delete('${UrlPaths.delete<NombreModelo>}/$id');
  }
}
```

## Convenciones del proyecto

| Concepto | Patrón |
|----------|--------|
| Inyección | Constructor recibe `BaseHttpClient` (no `StorageService` ni otros) |
| Métodos | Cada método = un endpoint. Retornan `Future<T>` |
| Paths dinámicos | `'${UrlPaths.constante}/$id/accion'` — concatenación inline |
| Respuestas | `response as List` → `.map((e) => Model.fromJson(e)).toList()` |
| | `response as Map<String, dynamic>` → `Model.fromJson(response)` |
| Parámetros query | `parameters: {'key': 'value'}` en GET |
| Body | `body: data` donde `data` es `Map<String, dynamic>` |
| Sin manejo de errores | Delegado a `BaseHttpClient._processResponse()` |
| Ubicación | `lib/app/data/repositories/` (repositorios compartidos) |

## Ejemplo del código real (OrdersRepository)

```dart
class OrdersRepository {
  final BaseHttpClient _client;

  OrdersRepository(this._client);

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    final response = await _client.post(UrlPaths.createOrder, body: data);
    return OrderModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> addOrderItems(
    String orderId,
    List<Map<String, dynamic>> products,
  ) async {
    await _client.put(
      '${UrlPaths.addProductsToOrder}/$orderId/add-products',
      body: {'products': products},
    );
  }

  Future<List<OrderModel>> getOrdersByStatuses(
    List<String> statuses, {
    String? date,
  }) async {
    final Map<String, String> params = {'statuses': statuses.join(',')};
    if (date != null) params['date'] = date;
    final response = await _client.get(
      UrlPaths.getOrdersByStatuses,
      parameters: params,
    );
    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }
}
```

## Reglas importantes

1. No importar ni usar `StorageService` directamente en repositorios
2. Siempre usar `UrlPaths.*` para endpoints (nunca strings hardcodeadas)
3. Si el endpoint no existe en `UrlPaths`, agregarlo siguiendo el patrón existente
4. Usar named parameters con `{}` para parámetros opcionales en métodos
5. Los repositorios son compartidos entre módulos — NO crear repositorios dentro de `modules/` (excepto perfil)
