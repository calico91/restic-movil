---
name: nuevo-modulo
description: "Crear un módulo completo (feature) siguiendo Clean Architecture + GetX Pattern para restic-movil: bindings, controllers, views, y registro en rutas"
---

## Qué hace esta skill

Genera el scaffolding completo de un nuevo módulo siguiendo la arquitectura feature-first del proyecto, incluyendo:
- Archivo de Binding con inyección de dependencias usando `Get.lazyPut` con `fenix: true`
- Controlador GetX con `onInit`/`onReady`/`onClose`, estado reactivo (`Rx`/`obs`), patrón `Get.showOverlay` para carga asíncrona
- Vista con `GetView<T>` usando `CustomScaffold` como wrapper obligatorio y `Obx` para reactividad
- Registro de rutas en `AppPages` y `Routes`

## Archivos a crear

```
lib/app/modules/<nombre_modulo>/
├── bindings/
│   └── <nombre_modulo>_binding.dart
├── controllers/
│   └── <nombre_modulo>_controller.dart
└── views/
    └── <nombre_modulo>_view.dart
```

## Archivos a modificar

- `lib/app/routes/app_routes.dart` — Agregar constante de ruta
- `lib/app/routes/app_pages.dart` — Agregar `GetPage` con import y binding

## Template de Binding

```dart
import 'package:get/get.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/repositories/<repositorio>.dart';
import '../controllers/<nombre_modulo>_controller.dart';

class <NombreModulo>Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BaseHttpClient(), fenix: true);
    Get.lazyPut(
      () => <Repositorio>Repository(Get.find<BaseHttpClient>()),
      fenix: true,
    );
    Get.lazyPut<<NombreModulo>Controller>(
      () => <NombreModulo>Controller(
        <repositorio>Repository: Get.find(),
      ),
      fenix: true,
    );
  }
}
```

## Template de Controller

```dart
import 'package:get/get.dart';
import 'package:restic_movil/app/data/repositories/<repositorio>_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';

class <NombreModulo>Controller extends GetxController {
  final <Repositorio>Repository <repositorio>Repository;
  final StorageService _storageService = Get.find<StorageService>();

  // --- Estado reactivo ---
  final RxBool isLoading = false.obs;
  final RxList<Modelo> items = <Modelo>[].obs;

  <NombreModulo>Controller({
    required this.<repositorio>Repository,
  });

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Inicializa datos necesarios al cargar el controlador
  void _initData() {}

  /// Carga los datos principales con overlay de carga
  Future<void> loadData() async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final result = await <repositorio>Repository.getData();
          items.assignAll(result);
        } catch (e) {
          final errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }
}
```

## Template de View

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import '../controllers/<nombre_modulo>_controller.dart';

class <NombreModulo>View extends GetView<<NombreModulo>Controller> {
  const <NombreModulo>View({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Título de la Pantalla',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.items.isEmpty) {
            return const Center(child: Text('Sin datos'));
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ListTile(title: Text(item.toString()));
            },
          );
        }),
      ),
    );
  }
}
```

## Template para app_routes.dart

```dart
static const <NOMBRE_MODULO> = '/<nombre-modulo>';
```

## Template para app_pages.dart

```dart
import '../modules/<nombre_modulo>/bindings/<nombre_modulo>_binding.dart';
import '../modules/<nombre_modulo>/views/<nombre_modulo>_view.dart';

// Dentro de la lista routes:
GetPage(
  name: Routes.<NOMBRE_MODULO>,
  page: () => const <NombreModulo>View(),
  binding: <NombreModulo>Binding(),
),
```

## Reglas importantes

1. **Snake_case** para archivos y carpetas; **CamelCase** para clases
2. Usar `Get.lazyPut` con `fenix: true` en los Bindings (nunca `Get.put` excepto en splash)
3. Usar `CustomScaffold` como wrapper obligatorio de toda vista
4. Usar `Obx` para widgets reactivos
5. Usar `Get.showOverlay` con `LoadingCharging` para operaciones asíncronas (evitar boolean `isLoading`)
6. Usar `ExceptionHandler.extractMessage(e)` + `ErrorSnackbar` para errores
7. Usar imports absolutos `package:restic_movil/...`
8. Nombres de rutas en kebab-case para paths (ej. `/mi-modulo`)
