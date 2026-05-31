import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restic_movil/app/data/services/storage_service.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import 'package:restic_movil/core/utils/snackbars/error_snackbar.dart';
import 'package:restic_movil/core/utils/snackbars/info_snackbar.dart';

class ConfigureConnectionController extends GetxController {
  final StorageService storageService;
  final serverController = TextEditingController();

  ConfigureConnectionController({required this.storageService});

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUrl();
  }

  static const String _urlSuffix = '.up.railway.app';

  Future<void> _loadCurrentUrl() async {
    // Extrae solo el nombre del cliente quitando el sufijo del dominio
    final String? currentUrl = await storageService.getServerUrl();
    if (currentUrl != null) {
      final String clientName = currentUrl.endsWith(_urlSuffix)
          ? currentUrl.substring(0, currentUrl.length - _urlSuffix.length)
          : currentUrl;
      serverController.text = clientName;
    }
  }

  @override
  void onClose() {
    serverController.dispose();
    super.onClose();
  }

  void saveConnection() async {
    // Concatena el sufijo del dominio al nombre del cliente antes de guardar
    final String clientName = serverController.text.trim();
    if (clientName.isEmpty) {
      Get.showSnackbar(const ErrorSnackbar('El nombre del servidor no puede estar vacío'));
      return;
    }
    final String fullUrl = '$clientName$_urlSuffix';
    await storageService.saveServerUrl(fullUrl);
    Get.back();
    Get.showSnackbar(const InfoSnackbar('Conexión configurada correctamente'));
  }
}

class ConfigureConnectionModal extends StatelessWidget {
  final StorageService storageService;

  const ConfigureConnectionModal({super.key, required this.storageService});

  static void show(StorageService storageService) {
    Get.dialog(
      ConfigureConnectionModal(storageService: storageService),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigureConnectionController>(
      init: ConfigureConnectionController(storageService: storageService),
      builder: (controller) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildDialogContent(context, controller),
        );
      },
    );
  }

  Widget _buildDialogContent(BuildContext context, ConfigureConnectionController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Configurar conexión',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D47A1),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.serverController,
            decoration: InputDecoration(
              labelText: 'Nombre del servidor',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.dns),
              suffixStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')), // Evitar espacios
            ],
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => controller.saveConnection(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: CustomSubmitButton(
              text: 'Guardar',
              onPressed: controller.saveConnection,
              backgroundColor: const Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }
}
