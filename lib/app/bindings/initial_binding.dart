import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/app/data/exceptions/http_exceptions.dart';
import 'package:restic_movil/app/data/http/base_http_client.dart';
import 'package:restic_movil/app/data/services/printer_service.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/data/services/subscription_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/modals/modal_info.dart';

class InitialBinding extends Bindings {
  static DateTime? _lastGuardNotice;

  bool _shouldShowNotice() {
    final now = DateTime.now();
    if (_lastGuardNotice != null &&
        now.difference(_lastGuardNotice!).inSeconds < 30) {
      return false;
    }
    _lastGuardNotice = now;
    return true;
  }

  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<PrinterService>(PrinterService(), permanent: true);
    Get.put<SubscriptionService>(SubscriptionService(), permanent: true);

    BaseHttpClient.addSubscriptionGuardCallback((error) async {
      final storage = Get.find<StorageService>();
      final user = await storage.getUser();
      final isAdmin = user?.modules?.contains('SUSCRIPCION') ?? false;

      if (isAdmin) {
        final subscriptionService = Get.find<SubscriptionService>();
        await subscriptionService.refreshStatus();
        if (Get.currentRoute != Routes.SUBSCRIPTION) {
          Get.toNamed(Routes.SUBSCRIPTION);
        }
        return;
      }

      if (!_shouldShowNotice()) return;
      final message = error is SubscriptionSuspendedException
          ? 'La suscripción del negocio está suspendida. Contacta a tu administrador.'
          : 'El negocio aún no tiene una suscripción activa. Contacta a tu administrador para iniciarla.';
      Get.dialog(ModalInfo(
        title: 'Acceso restringido',
        message: message,
        icon: Icons.lock_outline,
        iconColor: Colors.orange,
      ));
    });
  }
}