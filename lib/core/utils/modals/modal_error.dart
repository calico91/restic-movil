import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModalError extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;
  final String buttonText;
  final IconData icon;
  final Color iconColor;

  const ModalError({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onClose,
    this.buttonText = 'Cerrar',
    this.icon = Icons.error_outline,
    this.iconColor = const Color(0xFFB71C1C),
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 60),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose ?? () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
