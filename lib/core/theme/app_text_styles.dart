import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clase para definir los estilos de texto de la aplicación.
/// Usa [GoogleFonts.poppins] como fuente principal.
class AppTextStyles {
  // Fuente base
  static final TextStyle _baseTextStyle = GoogleFonts.poppins();

  // --- Display ---
  // Usado para textos muy grandes, introducciones, números grandes.
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: -0.25,
    height: 1.12,
  );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: 0,
    height: 1.16,
  );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: 0,
    height: 1.22,
  );

  // --- Headline ---
  // Usado para títulos de secciones importantes.
  static TextStyle get headlineLarge => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0,
    height: 1.25,
  );

  static TextStyle get headlineMedium => _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0,
    height: 1.29,
  );

  static TextStyle get headlineSmall => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0,
    height: 1.33,
  );

  // --- Title ---
  // Usado para títulos de widgets, diálogos, tarjetas.
  static TextStyle get titleLarge => _baseTextStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600, // SemiBold
    letterSpacing: 0,
    height: 1.27,
  );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get titleSmall => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.1,
    height: 1.43,
  );

  // --- Body ---
  // Usado para el contenido principal de lectura.
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.25,
    height: 1.43,
  );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0.4,
    height: 1.33,
  );

  // --- Label ---
  // Usado para textos pequeños, botones, captions.
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.1,
    height: 1.43,
  );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.5,
    height: 1.33,
  );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0.5,
    height: 1.45,
  );
}
