import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomFormDialog extends StatelessWidget {
  final String title;
  final FormGroup formGroup;
  final Widget child;
  final VoidCallback onSave;
  final String saveText;
  final String cancelText;
  final bool autoClose; // <- Nuevo campo

  const CustomFormDialog({
    super.key,
    required this.title,
    required this.formGroup,
    required this.child,
    required this.onSave,
    this.saveText = 'Guardar',
    this.cancelText = 'Cancelar',
    this.autoClose = true,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: formGroup,
      child: AlertDialog(
        backgroundColor: const Color(0xFFF5F6FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1), // Deep Blue del tema
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8),
            child: child,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[800],
                    side: BorderSide(color: Colors.red[800]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(cancelText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReactiveFormConsumer(
                  builder: (context, form, consumeChild) {
                    return ElevatedButton(
                      onPressed: form.valid
                          ? () {
                              if (autoClose) {
                                Get.back();
                              }
                              onSave();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Text(saveText),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
