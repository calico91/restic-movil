import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar controlador en vez de asignarlo a una variable no usada
    Get.find<SplashController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF64B5F6), // Azul vibrante suave
              Color(0xFFE57373), // Rojo vibrante suave
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.3, 0.9],
          ),
        ),
        child: AnimatedSplashScreen(
          duration: 3500, // Duración de la animación (dejando un margen antes de los 4s del controller)
          splash: Image.asset(
            'assets/icons/icono_app.png',
            width: 250,
            height: 250,
          ),
          nextScreen: const SizedBox.shrink(), // Placeholder porque GetX manejará la navegación
          disableNavigation: true,
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.fade,
          backgroundColor: Colors.transparent, // Deja ver el gradiente detrás
          splashIconSize: 250, // Permite que el ícono tenga su tamaño correcto
        ),
      ),
    );
  }
}
