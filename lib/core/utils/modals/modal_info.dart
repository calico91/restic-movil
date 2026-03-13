import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModalInfo extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;
  final String buttonText;
  final VoidCallback? onSecondaryAction;
  final String? secondaryButtonText;
  final IconData icon;
  final Color iconColor;

  const ModalInfo({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
    this.buttonText = 'Cerrar',
    this.onSecondaryAction,
    this.secondaryButtonText,
    this.icon = Icons.check_circle_outline,
    this.iconColor = Colors.green,
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
          if (onSecondaryAction != null && secondaryButtonText != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSecondaryAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1), // Deep Blue del tema
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.print, color: Colors.white, size: 20),
                label: Text(
                  secondaryButtonText!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: (onSecondaryAction != null)
                ? OutlinedButton(
                    onPressed: onClose ?? () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D47A1),
                      side: const BorderSide(color: Color(0xFF0D47A1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(buttonText),
                  )
                : ElevatedButton(
                    onPressed: onClose ?? () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
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
