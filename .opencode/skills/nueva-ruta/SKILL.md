---
name: nueva-ruta
description: "Agregar una nueva ruta/página al sistema de navegación GetX de restic-movil: constante en Routes, GetPage en AppPages, imports"
---

## Qué hace esta skill

Registra una nueva pantalla en el sistema de rutas del proyecto:
1. Agrega constante en `Routes` (`app_routes.dart`)
2. Agrega import y `GetPage` en `AppPages` (`app_pages.dart`)
3. Verifica que el módulo destino tenga su Binding y View creados

## Archivos a modificar

- `lib/app/routes/app_routes.dart` — Constante de ruta
- `lib/app/routes/app_pages.dart` — Registro de ruta + import

## Paso 1: Agregar constante en app_routes.dart

```dart
abstract class Routes {
  // ... rutas existentes ...
  static const <NOMBRE_MODULO> = '/<nombre-modulo>';
}
```

### Convenciones de nombres de ruta

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| Módulo raíz | `/<nombre>` | `/menu`, `/tables` |
| Módulo anidado | `/<padre>/<hijo>` | `/cash-register/open-shift` |
| Settings | `/settings/<nombre>` | `/settings/printer` |
| Constante Dart | `SNAKE_CASE` en mayúsculas | `PRINTER_SETTINGS` |

## Paso 2: Agregar GetPage en app_pages.dart

```dart
// 1. Import del Binding y View
import '../modules/<nombre_modulo>/bindings/<nombre_modulo>_binding.dart';
import '../modules/<nombre_modulo>/views/<nombre_modulo>_view.dart';

// 2. Agregar GetPage en la lista routes
class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // ... rutas existentes ...
    GetPage(
      name: Routes.<NOMBRE_MODULO>,
      page: () => const <NombreModulo>View(),
      binding: <NombreModulo>Binding(),
    ),
  ];
}
```

## Patrón del código real

Tomado de `app_pages.dart`:

```dart
// --- Import pattern ---
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/menu_view.dart';

// --- GetPage pattern ---
GetPage(
  name: Routes.MENU,
  page: () => const MenuView(),
  binding: MenuBinding(),
),
```

## Verificación después de agregar

- [ ] El módulo existe en `lib/app/modules/<nombre_modulo>/`
- [ ] El Binding tiene su método `dependencies()` implementado
- [ ] La View extiende `GetView<Controlador>`
- [ ] La constante en Routes es `UPPER_SNAKE_CASE`
- [ ] El path en Routes es kebab-case
- [ ] La View se importa con constructor `const`

## Reglas importantes

1. Mantener orden alfabético de imports y GetPages en `app_pages.dart`
2. El `INITIAL` siempre apunta a `Routes.SPLASH`
3. Usar `const` en el constructor de la View (`const MiView()`)
4. Los paths de rutas anidadas usan `/` para reflejar jerarquía (ej. `/settings/printer`)
5. Después de agregar la ruta, verificar que la navegación funciona con `Get.toNamed(Routes.MI_RUTA)`
