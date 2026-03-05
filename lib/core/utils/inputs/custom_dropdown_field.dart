import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveDropdownField<T> extends StatelessWidget {
  final String formControlName;
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final Map<String, String Function(Object)>? validationMessages;
  final Widget? prefixIcon;

  const CustomReactiveDropdownField({
    super.key,
    required this.formControlName,
    required this.labelText,
    required this.items,
    this.validationMessages,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveDropdownField<T>(
      formControlName: formControlName,
      validationMessages: validationMessages,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      items: items,
    );
  }
}
