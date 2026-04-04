import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/user_model.dart';
import 'package:restic_movil/app/modules/users/views/widgets/user_form_dialog.dart';
import 'package:restic_movil/core/theme/app_theme.dart';

void main() {
  group('Pruebas de Interfaz (Widget Tests) - UserFormDialog', () {
    testWidgets('Debe validar campos requeridos y no permitir guardar si están vacíos', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Get.dialog(
                        UserFormDialog(
                          roles: const [], // Probamos interfaz vacía inicial
                          onSubmit: (data) {}, // Acción al guardar
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Clic al botón simulado que abre el CustomFormDialog
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle(); // Esperamos a que la animación del diálogo termine

      // Verificamos que el título del modal esté en pantalla
      expect(find.text('Nuevo Usuario'), findsOneWidget);

      // El botón "Guardar" de CustomFormDialog se habilita solo si form.valid
      // Al ser reactivo e iniciar con todo vacío (username, name, email, etc. requeridos no llenados), debe estar bloqueado.
      final botonGuardarFinder = find.widgetWithText(ElevatedButton, 'Guardar');
      expect(botonGuardarFinder, findsOneWidget);

      // Intentamos oprimir Guardar
      final ElevatedButton botonGuardar = tester.widget(botonGuardarFinder);
      expect(botonGuardar.onPressed, isNull); // Es null porque form.valid = false (botón deshabilitado)
    });

    testWidgets('Validar autoClose = false (El submit se acciona pero el modal asume que el Controller lo cerrará)', (WidgetTester tester) async {
      bool submitLlamado = false;
      Map<String, dynamic>? datosEnviados;

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Get.dialog(
                        UserFormDialog(
                          roles: [
                            UserRole(id: 1, name: 'CAJA'),
                            UserRole(id: 2, name: 'SUPER')
                          ],
                          onSubmit: (data) {
                            submitLlamado = true;
                            datosEnviados = data;
                            // En la vida real, controller.createUser() decide si llamar Get.back(), 
                            // acá probamos que autoClose no lo hace por sí solo.
                          },
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      // Completamos TODOS los TextField que son obligatorios (*)
      await tester.enterText(find.widgetWithText(TextField, 'Usuario *'), 'johndoe');
      await tester.enterText(find.widgetWithText(TextField, 'Primer Nombre *'), 'John');
      await tester.enterText(find.widgetWithText(TextField, 'Primer Apellido *'), 'Doe');
      await tester.enterText(find.widgetWithText(TextField, 'Número Móvil *'), '3001234567');
      await tester.enterText(find.widgetWithText(TextField, 'Correo Electrónico *'), 'john@test.com');
      await tester.enterText(find.widgetWithText(TextField, 'Contraseña *'), '123456'); // Pass

      // Bajar el scroll o focus para ver los Checkbox
      await tester.ensureVisible(find.text('CAJA'));
      
      // Chequear rol requerido
      await tester.tap(find.text('CAJA'));
      await tester.pumpAndSettle();
      
      // Buscar botón de Guardar
      final botonGuardarFinder = find.widgetWithText(ElevatedButton, 'Guardar');
      final ElevatedButton botonGuardar = tester.widget(botonGuardarFinder);
      
      // Ahora debería estar habilitado (onPressed != null) ya que el frm es válido
      expect(botonGuardar.onPressed, isNotNull);

      // Lo oprimimos
      await tester.tap(botonGuardarFinder);
      await tester.pumpAndSettle(); // Esperamos que las tareas sincrónicas pasen

      // 1. Verificamos que onSubmit se llamó y recolectó la data enviada
      expect(submitLlamado, isTrue);
      expect(datosEnviados!['username'], 'johndoe');
      expect(datosEnviados!['roles'], contains('CAJA'));

      // 2. VERIFICACIÓN CENTRAL: El modal no debe haberse cerrado porque UserFormDialog pasa autoClose: false
      // Comprobamos verificando que el modal (sus textos de la UI) sigan en pantalla.
      expect(find.text('Nuevo Usuario'), findsOneWidget);
    });
  });
}
