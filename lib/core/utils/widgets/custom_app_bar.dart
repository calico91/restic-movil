import 'package:flutter/material.dart';
import 'package:restic_movil/core/utils/icons/back_arrow_icon.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? icons;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key, 
    required this.title, 
    this.icons,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: icons,
      leading: showBackButton ? BackArrowIcon(onPressed: onBack) : null,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
