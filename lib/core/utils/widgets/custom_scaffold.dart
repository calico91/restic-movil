import 'package:flutter/material.dart';
import 'package:restic_movil/core/utils/widgets/custom_app_bar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color backgroundColor;

  const CustomScaffold({
    super.key,
    required this.body,
    required this.title,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor = const Color(0xFFF5F6FA),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: title,
        showBackButton: showBackButton,
        onBack: onBack,
        icons: actions,
      ),
      drawer: drawer,
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          Column(
            children: [
              SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top + 10,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB71C1C), // Deep Red
            Color(0xFF0D47A1), // Deep Blue
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}
