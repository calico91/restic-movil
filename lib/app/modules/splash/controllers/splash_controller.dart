import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restic_movil/app/data/models/app_version_info.dart';
import 'package:restic_movil/app/data/repositories/app_version_repository.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/app/routes/app_routes.dart';
import 'package:restic_movil/core/utils/helpers/version_helper.dart';


class SplashController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  final AppVersionRepository appVersionRepository;

  SplashController({required this.appVersionRepository});

  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  /// Inicia el flujo de arranque: espera el splash, verifica si la version
  /// instalada es la minima requerida (fail-open si falla) y enruta a
  /// actualizacion obligatoria, home o login.
  void _startSplash() async {
    await Future.delayed(const Duration(seconds: 2));

    final forceUpdate = await _checkAppUpdate();
    if (forceUpdate) return;

    final token = await storageService.getToken();
    final branchId = await storageService.getBranchId();

    if (token != null &&
        token.isNotEmpty &&
        branchId != null &&
        branchId.isNotEmpty) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  /// Consulta el endpoint central de version y, si la app instalada es
  /// inferior a la version minima requerida, navega a la pantalla de
  /// actualizacion obligatoria. Cualquier error en la consulta se trata
  /// como fail-open y la app continua el flujo normal.
  /// Retorna `true` si se disparo la actualizacion obligatoria (en cuyo caso
  /// `_startSplash` debe abortar el flujo normal para no pisar la navegacion).
  Future<bool> _checkAppUpdate() async {
    String appVersion;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (_) {
      debugPrint('version check fail-open: no se pudo leer la version local');
      return false;
    }

    AppVersionInfo info;
    try {
      info = await appVersionRepository.getAppVersionInfo();
    } catch (_) {
      debugPrint('version check fail-open: no se pudo consultar la version central');
      return false;
    }

    final min = info.minRequiredVersion ?? 'desconocida';
    debugPrint('version minima $min version instalada $appVersion');

    if (VersionHelper.isLowerThan(appVersion, info.minRequiredVersion)) {
      debugPrint('forzar actualizacion: si');
      Get.offAllNamed(Routes.APP_UPDATE, arguments: info);
      return true;
    }
    debugPrint('forzar actualizacion: no');
    return false;
  }
}
