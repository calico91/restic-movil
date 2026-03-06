import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveTextField<T> extends StatelessWidget {
  final String? formControlName;
  final FormControl<T>? formControl;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Map<String, String Function(Object)>? validationMessages;
  final int maxLines;
  final int? maxLength;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;

  const CustomReactiveTextField({
    super.key,
    this.formControlName,
    this.formControl,
    this.labelText,
    this.hintText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validationMessages,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
  }) : assert(formControlName != null || formControl != null,
            'Must provide generic formControlName or formControl');

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField<T>(
      formControlName: formControlName,
      formControl: formControl,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      validationMessages: validationMessages,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 14), 
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        prefixText: prefixText,
        prefixIcon: prefixIcon != null
            ? IconTheme(
                data: IconThemeData(color: Colors.blue[900]),
                child: prefixIcon!,
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
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
    );
  }
}
