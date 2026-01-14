import 'package:restic_movil/app/data/exceptions/http_exceptions.dart';

class ExceptionHandler {
  /// metodo para extraer mensaje de error de una excepcion HttpException
  static String extractMessage(dynamic e, {String attribute = 'error'}) {
    if (e is HttpException) {
      if (e.body is Map && e.body[attribute] != null) {
        return e.body[attribute];
      }
      return e.message;
    }
    return e.toString();
  }
}
