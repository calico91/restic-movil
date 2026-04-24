import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorSnackbar extends GetSnackBar {
  const ErrorSnackbar(String message, {super.key}) : super(message: message);

  @override
  Widget? get messageText {
    return SelectableText(
      textAlign: TextAlign.center,
      message!,
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  SnackPosition get snackPosition => SnackPosition.TOP;

  @override
  Color get backgroundColor => const Color(0xFFB71C1C).withValues(alpha: 0.8);

  @override
  Duration? get duration => const Duration(seconds: 2);

  @override
  Widget? get icon => const Icon(Icons.error_outlined, color: Colors.white);

  @override
  Widget? get mainButton {
    return IconButton(
      color: Colors.white,
      onPressed: () => Get.back(),
      icon: const Icon(Icons.close),
    );
  }

  @override
  double get borderRadius => 15;
}
