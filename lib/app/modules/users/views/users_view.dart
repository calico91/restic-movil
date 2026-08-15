import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/user_model.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
import 'package:restic_movil/core/utils/buttons/custom_edit_button.dart';
import 'package:restic_movil/core/utils/buttons/custom_floating_action_button.dart';
import '../controllers/users_controller.dart';
import 'widgets/user_form_dialog.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  void _showUserForm(BuildContext context, [UserModel? user]) {
    Get.dialog(
      UserFormDialog(
        user: user,
        roles: controller.roles,
        onSubmit: (data) async {
          if (user == null) {
            await controller.createUser(data);
          } else {
            await controller.updateUser(user.id!, data);
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Gestionar Usuarios',
      body: Obx(() {
        if (controller.users.isEmpty) {
          return const Center(child: Text('No hay usuarios registrados'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: user.isActive
                      ? const Color(0xFF0D47A1)
                      : Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName
                      : (user.username ?? 'Sin nombre'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email ?? 'Sin correo'),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: user.roles
                          .map(
                            (role) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0D47A1,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF0D47A1),
                                ),
                              ),
                              child: Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: user.isActive,
                      onChanged: (value) {
                         Get.dialog(
                          AlertDialog(
                            title: Text(value ? 'Activar Usuario' : 'Desactivar Usuario'),       
                            content: Text(
                              '¿Estás seguro de que quieres ${value ? 'activar' : 'desactivar'} a ${user.username}?'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE52E2D)),
                                onPressed: () {
                                  Get.back();
                                  controller.toggleUserStatus(user);       
                                },
                                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      activeThumbColor: const Color(0xFF0D47A1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.vpn_key_sharp, color: Color(0xFFE52E2D)),
                      tooltip: 'Restablecer Contraseña',
                      onPressed: () {
                        // Dialog de confirmación
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Restablecer Contraseña'),
                            content: Text(
                              '¿Estas seguro de que quieres restablecer la contrasena de ${user.username}? Se generara una nueva contrasena temporal.'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE52E2D)),
                                onPressed: () {
                                  Get.back();
                                  controller.resetUserPassword(user.username!, user.id!);
                                },
                                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    CustomEditButton(
                      onPressed: () => _showUserForm(context, user),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () => _showUserForm(context),
      ),
    );
  }
}
