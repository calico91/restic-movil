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
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: IconThemeData(color: Colors.blue[900]),
                child: prefixIcon!,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50], // Sutil, pero elegante
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      items: items,
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: Colors.blue.shade900), // Flecha personalizada
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(20),
    );
  }
}
