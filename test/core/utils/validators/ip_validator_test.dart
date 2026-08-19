import 'package:flutter_test/flutter_test.dart';
import 'package:restic_movil/core/utils/validators/ip_validator.dart';

void main() {
  group('IpValidator - casos invalidos', () {
    test('null retorna mensaje de obligatorio', () {
      final String? result = IpValidator.validate(null);
      expect(result, isNotNull);
      expect(result, contains('obligatoria'));
    });

    test('vacio retorna mensaje de obligatorio', () {
      final String? result = IpValidator.validate('');
      expect(result, isNotNull);
      expect(result, contains('obligatoria'));
    });

    test('solo espacios retorna mensaje de obligatorio', () {
      final String? result = IpValidator.validate('   ');
      expect(result, isNotNull);
      expect(result, contains('obligatoria'));
    });

    test('3 octetos (caso del usuario: 12.9.1) es invalido', () {
      final String? result = IpValidator.validate('12.9.1');
      expect(result, isNotNull);
      expect(result, contains('4 octetos'));
    });

    test('octeto > 255 es invalido', () {
      final String? result = IpValidator.validate('192.168.1.300');
      expect(result, isNotNull);
      expect(result, contains('fuera de rango'));
    });

    test('octeto con cero leading es invalido', () {
      final String? result = IpValidator.validate('192.168.01.1');
      expect(result, isNotNull);
      expect(result, contains('no debe tener ceros a la izquierda'));
    });

    test('octeto no numerico es invalido', () {
      final String? result = IpValidator.validate('192.168.1.abc');
      expect(result, isNotNull);
      expect(result, contains('no es numerico'));
    });

    test('5 octetos es invalido', () {
      final String? result = IpValidator.validate('192.168.1.1.5');
      expect(result, isNotNull);
      expect(result, contains('4 octetos'));
    });

    test('2 octetos es invalido', () {
      final String? result = IpValidator.validate('192.168');
      expect(result, isNotNull);
      expect(result, contains('4 octetos'));
    });

    test('octeto vacio (192..1.1) es invalido', () {
      final String? result = IpValidator.validate('192..1.1');
      expect(result, isNotNull);
      expect(result, contains('octeto vacio'));
    });

    test('todos los mensajes de error contienen el ejemplo', () {
      const List<String?> inputs = <String?>[
        null,
        '',
        '12.9.1',
        '192.168.1.300',
        '192.168.01.1',
        '192.168.1.abc',
        '192.168.1.1.5',
        '192..1.1',
      ];
      for (final String? input in inputs) {
        final String? result = IpValidator.validate(input);
        expect(result, isNotNull);
        expect(result, contains(IpValidator.example),
            reason: 'El mensaje para "$input" debe incluir el ejemplo');
      }
    });
  });

  group('IpValidator - casos validos', () {
    test('192.168.1.100 es valida', () {
      expect(IpValidator.validate('192.168.1.100'), isNull);
    });

    test('10.0.0.1 es valida', () {
      expect(IpValidator.validate('10.0.0.1'), isNull);
    });

    test('255.255.255.255 es valida (limite superior)', () {
      expect(IpValidator.validate('255.255.255.255'), isNull);
    });

    test('0.0.0.0 es valida (limite inferior)', () {
      expect(IpValidator.validate('0.0.0.0'), isNull);
    });

    test('127.0.0.1 es valida (localhost)', () {
      expect(IpValidator.validate('127.0.0.1'), isNull);
    });

    test('acepta espacios al inicio/final (los recorta)', () {
      expect(IpValidator.validate('  192.168.1.100  '), isNull);
    });
  });
}
