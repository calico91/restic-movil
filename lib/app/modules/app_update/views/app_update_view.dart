import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restic_movil/core/utils/widgets/custom_scaffold.dart';

import '../controllers/app_update_controller.dart';

class AppUpdateView extends GetView<AppUpdateController> {
  const AppUpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: CustomScaffold(
        title: 'Actualización requerida',
        showBackButton: false,
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildIcon(),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 12),
          Obx(() => _buildMessage()),
          const SizedBox(height: 16),
          Obx(() => _buildVersionInfo()),
          const Spacer(),
          Obx(() => _buildActions()),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFFB71C1C).withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.system_update_alt,
          size: 56,
          color: Color(0xFFB71C1C),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Hay una nueva versión disponible',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      controller.message.value,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF555555),
        height: 1.4,
      ),
    );
  }

  Widget _buildVersionInfo() {
    if (controller.minRequiredVersion.value.isEmpty &&
        controller.latestVersion.value.isEmpty) {
      return const SizedBox.shrink();
    }
    final parts = <String>[];
    if (controller.latestVersion.value.isNotEmpty) {
      parts.add('Última versión: ${controller.latestVersion.value}');
    }
    if (controller.minRequiredVersion.value.isNotEmpty) {
      parts.add('Versión mínima requerida: ${controller.minRequiredVersion.value}');
    }
    return Text(
      parts.join('  •  '),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF888888),
      ),
    );
  }

  Widget _buildActions() {
    final canOpen = controller.storeUrl.value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canOpen && !controller.isOpeningStore.value
                ? controller.openStore
                : null,
            icon: const Icon(Icons.shop, color: Colors.white),
            label: Text(
              controller.isOpeningStore.value
                  ? 'Abriendo tienda...'
                  : 'Actualizar ahora',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFB71C1C),
              disabledBackgroundColor: const Color(0xFFCCCCCC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.isChecking.value ? null : controller.retry,
            icon: const Icon(Icons.refresh, color: Color(0xFF0D47A1)),
            label: Text(
              controller.isChecking.value ? 'Verificando...' : 'Reintentar',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: const Color(0xFF0D47A1),
              side: const BorderSide(color: Color(0xFF0D47A1), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
