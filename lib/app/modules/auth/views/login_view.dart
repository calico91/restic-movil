import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:restic_movil/core/utils/inputs/custom_text_field.dart';
import 'package:restic_movil/core/utils/buttons/custom_submit_button.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          _buildMainContent(context),
          _buildVersionText(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFe3f2fd), // Hielo - azul muy claro
            Color(0xFFffebee), // Fuego suave - rojo/rosado muy claro
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.3, 0.9],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: _buildCardDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: 30),
                        _buildForm(),
                        const SizedBox(height: 20),
                        _buildLoginButton(),
                        const SizedBox(height: 20),
                        _buildRegisterLink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.85), // Efecto translúcido Material M3
      borderRadius: BorderRadius.circular(32), // Curvatura más moderna
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0D47A1).withValues(alpha: 0.05), // Sombra azul sutil
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.5), // Borde claro para efecto cristal
        width: 1.5,
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB71C1C).withValues(alpha: 0.1), // Sombra cálida
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/icono_app.png',
          height: 120, 
          width: 120, 
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          '¡Bienvenido!',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0D47A1), // Deep blue theme
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gestiona tu negocio fácilmente',
          style: GoogleFonts.poppins(
            fontSize: 14, 
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return ReactiveForm(
      formGroup: controller.form,
      child: Column(
        children: [
          const CustomReactiveTextField<String>(
            formControlName: 'username',
            labelText: 'Usuario',
          ),
          const SizedBox(height: 20),
          Obx(
            () => CustomReactiveTextField<String>(
              formControlName: 'password',
              obscureText: !controller.isPasswordVisible.value,
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56, // Altura moderna tactil
      child: CustomSubmitButton(
        text: 'Ingresar',
        onPressed: controller.login,
        backgroundColor: const Color(0xFFB71C1C), // Fuego/Rojo profundo
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: controller.configureConnection,
          child: Text(
            'Configurar conexión',
            style: GoogleFonts.poppins(
              color: Colors.blue[800],
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionText() {
    return Align(
      alignment: Alignment.bottomCenter, // Centrado para equilibrar diseño
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Text(
            controller.appVersion.value.isNotEmpty
                ? controller.appVersion.value
                : 'Versión -.-',
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
