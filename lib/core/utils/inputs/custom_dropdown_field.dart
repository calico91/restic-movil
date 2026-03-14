import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveDropdownField<T> extends StatelessWidget {
  final String? formControlName;
  final FormControl<T>? formControl;
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final Map<String, String Function(Object)>? validationMessages;
  final Widget? prefixIcon;

  const CustomReactiveDropdownField({
    super.key,
    this.formControlName,
    this.formControl,
    required this.labelText,
    required this.items,
    this.validationMessages,
    this.prefixIcon,
  }) : assert(
         formControlName != null || formControl != null,
         'Must provide generic formControlName or formControl',
       );

  @override
  Widget build(BuildContext context) {
    return ReactiveDropdownField<T>(
      isExpanded: true,
      formControlName: formControlName,
      formControl: formControl,
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
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      items: items,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.blue.shade900,
      ), // Flecha personalizada
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
