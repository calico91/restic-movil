import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restic_movil/app/data/models/app_version_info.dart';
import 'package:restic_movil/app/data/repositories/app_version_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/helpers/version_helper.dart';
import 'package:restic_movil/core/utils/modals/modal_error.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateController extends GetxController {
  final AppVersionRepository appVersionRepository;

  AppUpdateController({required this.appVersionRepository});

  final RxString latestVersion = ''.obs;
  final RxString minRequiredVersion = ''.obs;
  final RxString storeUrl = ''.obs;
  final RxString message = ''.obs;
  final RxBool isOpeningStore = false.obs;
  final RxBool isChecking = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is AppVersionInfo) {
      _apply(args);
    }
  }

  void _apply(AppVersionInfo info) {
    latestVersion.value = info.latestVersion ?? '';
    minRequiredVersion.value = info.minRequiredVersion ?? '';
    message.value = info.message ??
        'Hay una nueva versión disponible. Por favor actualice la aplicación para continuar.';
    if (Platform.isIOS && (info.iosStoreUrl?.isNotEmpty ?? false)) {
      storeUrl.value = info.iosStoreUrl!;
    } else {
      storeUrl.value = info.androidStoreUrl ?? '';
    }
  }

  Future<void> openStore() async {
    if (storeUrl.value.isEmpty || isOpeningStore.value) return;
    isOpeningStore.value = true;
    try {
      final uri = Uri.parse(storeUrl.value);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        _showError('No se pudo abrir la tienda');
      }
    } catch (_) {
      _showError('No se pudo abrir la tienda');
    } finally {
      isOpeningStore.value = false;
    }
  }

  Future<void> retry() async {
    if (isChecking.value) return;
    isChecking.value = true;
    try {
      final info = await appVersionRepository.getAppVersionInfo();
      _apply(info);

      final packageInfo = await PackageInfo.fromPlatform();
      final min = info.minRequiredVersion ?? 'desconocida';
      debugPrint(
          'version minima $min version instalada ${packageInfo.version}');

      if (!VersionHelper.isLowerThan(
          packageInfo.version, info.minRequiredVersion)) {
        debugPrint('forzar actualizacion: no');
        await _navigateToNormalFlow();
      } else {
        debugPrint('forzar actualizacion: si');
        Get.dialog(
          const ModalError(
            message:
                'La versión instalada aún no cumple el requisito mínimo.',
          ),
        );
      }
    } catch (_) {
      _showError(
          'No se pudo verificar la versión. Verifique su conexión a internet.');
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> _navigateToNormalFlow() async {
    final storage = Get.find<StorageService>();
    final token = await storage.getToken();
    final branchId = await storage.getBranchId();
    if (token != null &&
        token.isNotEmpty &&
        branchId != null &&
        branchId.isNotEmpty) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _showError(String text) {
    Get.snackbar(
      'Error',
      text,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFB71C1C).withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}
