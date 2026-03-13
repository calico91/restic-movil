import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color iconColor;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Colors.blue[900],
      child: Icon(icon, color: iconColor),
    );
  }
}
