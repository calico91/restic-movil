import 'package:flutter/material.dart';

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;
  final double size;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    this.size = 24.0,
    this.padding,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: padding ?? const EdgeInsets.all(8.0),
      constraints: constraints,
    );
  }
}
