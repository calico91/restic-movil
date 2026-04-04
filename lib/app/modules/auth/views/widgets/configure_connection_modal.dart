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

  Future<void> _loadCurrentUrl() async {
    final currentUrl = await storageService.getServerUrl();
    if (currentUrl != null) {
      serverController.text = currentUrl;
    }
  }

  @override
  void onClose() {
    serverController.dispose();
    super.onClose();
  }

  void saveConnection() async {
    final url = serverController.text.trim();
    if (url.isEmpty) {
      Get.showSnackbar(const ErrorSnackbar('El servidor no puede estar vacío'));
      return;
    }
    
    await storageService.saveServerUrl(url);
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
              labelText: 'Servidor',
              hintText: 'Ej. 192.168.0.103:8093',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.dns),
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
