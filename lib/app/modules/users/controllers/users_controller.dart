import 'package:get/get.dart';
import 'package:restic_movil/app/data/models/login_response.dart';
import 'package:restic_movil/app/data/models/user_model.dart';
import 'package:restic_movil/app/data/repositories/users_repository.dart';
import 'package:restic_movil/core/utils/animations/loading_charging.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';

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
          final errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }

  /* Crea un nuevo usuario y actualiza la lista */
  Future<void> createUser(Map<String, dynamic> data) async {
    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final newUser = await _repository.createUser(data);
          users.add(newUser);
          Get.dialog(
            ModalInfo(
              title: 'Éxito',
              message: 'Usuario creado exitosamente',
              onClose: () => Get.back(),
            ),
          );
        } catch (e) {
          final errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }

  /* Actualiza un usuario existente y actualiza la lista */
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await Get.showOverlay(
      loadingWidget: const LoadingCharging(),
      asyncFunction: () async {
        try {
          final updatedUser = await _repository.updateUser(id, data);
          final index = users.indexWhere((u) => u.id == id);
          if (index != -1) {
            users[index] = updatedUser;
          }
          Get.dialog(
            ModalInfo(
              title: 'Éxito',
              message: 'Usuario actualizado exitosamente',
              onClose: () => Get.back(),
            ),
          );
        } catch (e) {
          final errorMessage = ExceptionHandler.extractMessage(e);
          Get.showSnackbar(ErrorSnackbar(errorMessage));
        }
      },
    );
  }
}
