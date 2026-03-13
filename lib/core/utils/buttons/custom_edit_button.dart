import 'package:flutter/material.dart';

class CustomEditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final double iconSize;

  const CustomEditButton({
    super.key,
    required this.onPressed,
    this.label,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    const editColor = Color(0xFF0D47A1);

    if (label != null) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.edit, size: iconSize, color: editColor),
        label: Text(
          label!,
          style: const TextStyle(color: editColor, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: editColor.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: editColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(Icons.edit, color: editColor, size: iconSize),
        onPressed: onPressed,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
