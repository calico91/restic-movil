import 'package:get/get.dart';
import 'package:restic_movil/app/data/exceptions/http_exceptions.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/helpers/exception_handler.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';

class ErrorHandler {
  static void showErrorDialog(dynamic error) {
    final sessionExpired = _isSessionExpired(error);
    final message = error is String
        ? error
        : ExceptionHandler.extractMessage(error);

    if (sessionExpired) {
      Get.dialog(
        ModalError(
          title: 'Sesión expirada',
          message: message,
          buttonText: 'Ir a inicio de sesión',
          onClose: () => Get.offAllNamed(Routes.LOGIN),
        ),
        barrierDismissible: false,
      );
      return;
    }

    Get.dialog(ModalError(message: message));
  }

  static bool _isSessionExpired(dynamic error) {
    if (error is! HttpException) return false;
    final body = error.body;
    return body is Map && body['code'] == 'E2';
  }
}
