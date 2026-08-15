import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/user_model.dart';
import 'package:restic_movil/app/data/repositories/users_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/helpers/error_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class UsersController extends GetxController {
  final UsersRepository _repository;

  UsersController(this._repository);

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserRole> roles = <UserRole>[].obs;

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

  /* Carga la lista inicial de usuarios y roles */
  Future<void> _loadInitialData() async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final usersData = await _repository.getUsers();
          final rolesData = await _repository.getRoles();
          users.assignAll(usersData);
          roles.assignAll(rolesData);
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  /* Crea un nuevo usuario y actualiza la lista */
  Future<bool> createUser(Map<String, dynamic> data) async {
    bool isSuccess = false;
    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final newUser = await _repository.createUser(data);
          users.add(newUser);
          isSuccess = true;
        } catch (e) {
          final errorMessage = ExceptionHandler.extractMessage(e);
          Get.dialog(ModalError(message: errorMessage));
        }
      },
    );

    if (isSuccess) {
      Get.back(); // Cierra el UserFormDialog
      Get.dialog(
        ModalInfo(
          title: 'Éxito',
          message: 'Usuario creado exitosamente',
          onClose: () => Get.back(),
        ),
      );
    }

    return isSuccess;
  }

  /* Actualiza un usuario existente y actualiza la lista */
  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    bool isSuccess = false;
    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final updatedUser = await _repository.updateUser(id, data);
          final index = users.indexWhere((u) => u.id == id);
          if (index != -1) {
            users[index] = updatedUser;
          }
          isSuccess = true;
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );

    if (isSuccess) {
      Get.back(); // Cierra el UserFormDialog
      Get.dialog(
        ModalInfo(
          title: 'Éxito',
          message: 'Usuario actualizado exitosamente',
          onClose: () => Get.back(),
        ),
      );
    }

    return isSuccess;
  }

  /// Restablece la contraseña de un usuario generando una temporal con SecureRandom.
  Future<void> resetUserPassword(String username, String id) async {
    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final result = await _repository.resetPassword(id);
          _showGeneratedPasswordDialog(username, result.temporaryPassword);
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }

  void _showGeneratedPasswordDialog(String username, String password) {
    Get.dialog(
      AlertDialog(
        title: const Text('Contrasena temporal generada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuario: $username'),
            const SizedBox(height: 12),
            const Text(
              'Comparte esta contrasena con el usuario. Se mostrara solo una vez:',
            ),
            const SizedBox(height: 8),
            SelectableText(
              password,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El usuario debera cambiarla en su proximo inicio de sesion.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Activa o desactiva (toggle) un usuario
  Future<void> toggleUserStatus(UserModel user) async {
    if (user.id == null) return;

    Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          await _repository.toggleUserStatus(user.id!);
          // Refresh list to show updated status
          await _loadInitialData();
          Get.showSnackbar(
            InfoSnackbar(
              'El estado del usuario ${user.username} ha sido actualizado',
            ),
          );
        } catch (e) {
          ErrorHandler.showErrorDialog(e);
        }
      },
    );
  }
}
