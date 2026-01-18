import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackArrowIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;

  const BackArrowIcon({
    super.key, 
    this.onPressed,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color),
      onPressed: onPressed ?? () => Get.back(),
    );
  }
}
