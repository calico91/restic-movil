import 'package:flutter_test/flutter_test.dart';
import 'package:restic_movil/core/utils/helpers/version_helper.dart';

void main() {
  group('VersionHelper.compare', () {
    test('versiones iguales retornan 0', () {
      expect(VersionHelper.compare('2.0.6', '2.0.6'), 0);
    });

    test('a menor que b retorna -1', () {
      expect(VersionHelper.compare('2.0.5', '2.0.6'), -1);
    });

    test('a mayor que b retorna 1', () {
      expect(VersionHelper.compare('2.0.7', '2.0.6'), 1);
    });

    test('compara segmentos faltantes como 0 (1.0 == 1.0.0)', () {
      expect(VersionHelper.compare('1.0', '1.0.0'), 0);
    });

    test('compara segmentos faltantes como 0 (2.0 < 2.0.1)', () {
      expect(VersionHelper.compare('2.0', '2.0.1'), -1);
    });

    test('compara segmentos faltantes como 0 (2.0.1 > 2.0)', () {
      expect(VersionHelper.compare('2.0.1', '2.0'), 1);
    });

    test('compara correctamente 2.1 vs 2.0.10', () {
      expect(VersionHelper.compare('2.1', '2.0.10'), 1);
    });

    test('compara correctamente 10.0.0 vs 9.99.99', () {
      expect(VersionHelper.compare('10.0.0', '9.99.99'), 1);
    });

    test('segmentos no numericos se tratan como 0', () {
      expect(VersionHelper.compare('2.0.x', '2.0.0'), 0);
    });

    test('tolera espacios al inicio y al final', () {
      expect(VersionHelper.compare(' 2.0.6 ', '2.0.6'), 0);
    });
  });

  group('VersionHelper.isLowerThan', () {
    test('appVersion null retorna false (fail-open)', () {
      expect(VersionHelper.isLowerThan(null, '2.0.0'), false);
    });

    test('minRequiredVersion null retorna false (fail-open)', () {
      expect(VersionHelper.isLowerThan('2.0.0', null), false);
    });

    test('ambos null retorna false (fail-open)', () {
      expect(VersionHelper.isLowerThan(null, null), false);
    });

    test('strings vacios retornan false (fail-open)', () {
      expect(VersionHelper.isLowerThan('', ''), false);
      expect(VersionHelper.isLowerThan('', '2.0.0'), false);
      expect(VersionHelper.isLowerThan('2.0.0', ''), false);
    });

    test('appVersion menor que minRequiredVersion retorna true', () {
      expect(VersionHelper.isLowerThan('2.0.5', '2.0.6'), true);
    });

    test('appVersion igual a minRequiredVersion retorna false', () {
      expect(VersionHelper.isLowerThan('2.0.6', '2.0.6'), false);
    });

    test('appVersion mayor que minRequiredVersion retorna false', () {
      expect(VersionHelper.isLowerThan('2.0.7', '2.0.6'), false);
    });

    test('appVersion con segmentos faltantes funciona correctamente', () {
      expect(VersionHelper.isLowerThan('2.0', '2.0.1'), true);
      expect(VersionHelper.isLowerThan('2.0.1', '2.0'), false);
    });
  });
}
