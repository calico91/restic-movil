import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/user_model.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';
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
        onSubmit: (data) {
          if (user == null) {
            controller.createUser(data);
          } else {
            controller.updateUser(user.id!, data);
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
                  backgroundColor: user.isActive ? Colors.blue : Colors.grey,
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
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showUserForm(context, user),
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
