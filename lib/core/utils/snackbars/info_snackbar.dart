import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InfoSnackbar extends GetSnackBar {
  const InfoSnackbar(String message, {super.key}) : super(message: message);

  @override
  Widget? get messageText {
    return SelectableText(
      message!,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  SnackPosition get snackPosition => SnackPosition.TOP;

  @override
  Color get backgroundColor => Colors.blue[600]!;

  @override
  Duration? get duration => const Duration(seconds: 3);

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
