/// Validador de direcciones IPv4 estrictas.
///
/// Reglas:
/// - 4 octetos separados por ".".
/// - Cada octeto entre 0 y 255 (inclusive).
/// - Sin ceros leading (ej. "01" no se acepta; usar "1").
/// - Solo digitos en cada octeto.
class IpValidator {
  IpValidator._();

  /// Ejemplo canonico usado en los mensajes de error.
  static const String example = '192.168.1.100';

  /// Valida una IPv4. Retorna `null` si es valida, o un mensaje
  /// descriptivo si no lo es.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La IP es obligatoria. Ejemplo: $example';
    }
    final String v = value.trim();
    final List<String> parts = v.split('.');
    if (parts.length != 4) {
      return 'La IP debe tener 4 octetos separados por "."\n'
          'Ejemplo valido: $example';
    }
    for (int i = 0; i < parts.length; i++) {
      final String p = parts[i];
      if (p.isEmpty) {
        return 'Hay un octeto vacio en la posicion ${i + 1}.\n'
            'Ejemplo valido: $example';
      }
      if (p.length > 1 && p.startsWith('0')) {
        return 'El octeto "$p" no debe tener ceros a la izquierda.\n'
            'Ejemplo valido: $example';
      }
      final int? n = int.tryParse(p);
      if (n == null) {
        return 'El octeto "$p" no es numerico.\n'
            'Ejemplo valido: $example';
      }
      if (n < 0 || n > 255) {
        return 'El octeto "$p" esta fuera de rango (0-255).\n'
            'Ejemplo valido: $example';
      }
    }
    return null;
  }
}
