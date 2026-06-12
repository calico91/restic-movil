---
name: testing
description: "Escribir tests unitarios y de widgets para restic-movil usando flutter_test con GetX, mocks de repositorios y patrones de inyección de dependencias"
---

## Qué hace esta skill

Crea tests siguiendo las convenciones del proyecto:
- Tests unitarios para Controladores, Repositorios y Modelos
- Tests de widgets para validar comportamiento visual
- Mocks de repositorios y servicios con clases manuales (sin package de mocking)
- Configuración de GetX con `Get.put`/`Get.lazyPut` en setup
- Pruebas orientadas a roles (SUPER, ADMINISTRADOR, CAJA, COCINA)

## Archivos a crear

```
test/modules/<nombre_modulo>/<componente>_test.dart
test/data/models/<modelo>_test.dart
test/data/repositories/<repositorio>_test.dart
```

## Template de test unitario para Controller

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/repositories/<repositorio>_repository.dart';
import 'package:restic_movil/app/modules/<nombre_modulo>/controllers/<nombre_modulo>_controller.dart';

// Mock del repositorio
class Mock<Repositorio>Repository implements <Repositorio>Repository {
  // Implementar métodos mock según necesidad del test
}

void main() {
  late Mock<Repositorio>Repository mockRepository;

  setUp(() {
    mockRepository = Mock<Repositorio>Repository();
    Get.put<<NombreModulo>Controller>(
      <NombreModulo>Controller(
        <repositorio>Repository: mockRepository,
      ),
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('<NombreModulo>Controller', () {
    test('debe inicializar correctamente', () {
      final controller = Get.find<<NombreModulo>Controller>();
      expect(controller, isNotNull);
    });
  });
}
```

## Template de test para Modelo

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:restic_movil/app/data/models/<modelo>_model.dart';

void main() {
  group('<NombreModelo>Model', () {
    test('fromJson debe crear instancia correctamente', () {
      final json = {
        'id': '1',
        'name': 'Test',
        'active': true,
      };
      final model = <NombreModelo>Model.fromJson(json);
      expect(model.id, '1');
      expect(model.name, 'Test');
      expect(model.active, isTrue);
    });

    test('toJson debe serializar correctamente', () {
      final model = <NombreModelo>Model(
        id: '1',
        name: 'Test',
        active: true,
      );
      final json = model.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'Test');
      expect(json['active'], isTrue);
    });

    test('fromJson con null debe manejar valores nulos', () {
      final json = <String, dynamic>{};
      final model = <NombreModelo>Model.fromJson(json);
      expect(model.id, isNull);
      expect(model.name, isNull);
    });
  });
}
```

## Template de test de Widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/modules/<nombre_modulo>/views/<nombre_modulo>_view.dart';
import 'package:restic_movil/app/modules/<nombre_modulo>/controllers/<nombre_modulo>_controller.dart';

Widget createTestWidget() {
  return GetMaterialApp(
    home: const <NombreModulo>View(),
  );
}

void main() {
  setUp(() {
    Get.put<<NombreModulo>Controller>(<NombreModulo>Controller(
      <repositorio>Repository: Mock<Repositorio>Repository(),
    ));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('debe mostrar el titulo correcto', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Título de la Pantalla'), findsOneWidget);
  });
}
```

## Patrones de prueba orientados a roles

```dart
group('Roles de usuario', () {
  test('usuario COCINA no debe tener acceso a modulo CAJA', () {
    // Simular LoginResponse con rol COCINA
    // Verificar que no se pueda acceder a la ruta de caja
  });

  test('usuario ADMINISTRADOR debe tener acceso completo', () {
    // Simular LoginResponse con rol ADMINISTRADOR
    // Verificar acceso a todos los módulos
  });
});
```

## Comandos para ejecutar tests

```bash
flutter test                                          # Todos los tests
flutter test test/modules/<nombre_modulo>              # Tests de un módulo
flutter test test/data/models/<modelo>_test.dart       # Test específico
```

## Reglas importantes

1. Usar `flutter_test` exclusivamente (sin paquetes de testing externos como `mockito`)
2. Crear mocks manuales implementando la interfaz de repositorios/servicios
3. Llamar `Get.reset()` en `tearDown` para limpiar DI entre tests
4. Envolver widgets con `GetMaterialApp` para que GetX funcione en tests
5. Usar `pumpAndSettle()` después de operaciones asíncronas
6. Escribir descripciones de tests siempre en español
7. Ubicar tests en `test/` reflejando la misma estructura que `lib/`
