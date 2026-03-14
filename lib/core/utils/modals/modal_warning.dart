import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModalWarning extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;
  final String buttonText;
  final VoidCallback? onSecondaryAction;
  final String? secondaryButtonText;
  final IconData icon;
  final Color iconColor;

  const ModalWarning({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
    this.buttonText = 'Cerrar',
    this.onSecondaryAction,
    this.secondaryButtonText,
    this.icon = Icons.warning_amber_rounded,
    this.iconColor = Colors.orange,
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
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.settings, color: Colors.white, size: 20),
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
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(buttonText),
                  )
                : ElevatedButton(
                    onPressed: onClose ?? () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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
