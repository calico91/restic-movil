import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:restic_movil/app/data/repositories/app_version_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.env['APP_VERSION_CHECK_URL'] = 'https://example.com/version.json';
  });

  tearDown(() {
    dotenv.env.remove('APP_VERSION_CHECK_URL');
  });

  group('AppVersionRepository.getAppVersionInfo', () {
    test('parsea un JSON valido correctamente', () async {
      final mock = MockClient((request) async {
        expect(request.url.toString(), 'https://example.com/version.json');
        return http.Response(
          jsonEncode({
            'latestVersion': '2.0.7',
            'minRequiredVersion': '2.0.5',
            'androidStoreUrl': 'https://play.google.com/store/apps/details?id=x',
            'iosStoreUrl': 'https://apps.apple.com/app/id1',
            'message': 'Actualice la aplicacion',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AppVersionRepository(client: mock);
      final info = await repo.getAppVersionInfo();

      expect(info.latestVersion, '2.0.7');
      expect(info.minRequiredVersion, '2.0.5');
      expect(info.androidStoreUrl,
          'https://play.google.com/store/apps/details?id=x');
      expect(info.iosStoreUrl, 'https://apps.apple.com/app/id1');
      expect(info.message, 'Actualice la aplicacion');
    });

    test('lanza excepcion cuando el status no es 2xx', () async {
      final mock = MockClient((request) async {
        return http.Response('not found', 404);
      });

      final repo = AppVersionRepository(client: mock);
      expect(
        () => repo.getAppVersionInfo(),
        throwsA(isA<Exception>()),
      );
    });

    test('lanza excepcion cuando la respuesta no es JSON valido', () async {
      final mock = MockClient((request) async {
        return http.Response('esto no es json', 200);
      });

      final repo = AppVersionRepository(client: mock);
      expect(
        () => repo.getAppVersionInfo(),
        throwsA(isA<Exception>()),
      );
    });

    test('lanza excepcion cuando la URL no esta configurada', () async {
      dotenv.env.remove('APP_VERSION_CHECK_URL');
      final repo = AppVersionRepository();
      expect(
        () => repo.getAppVersionInfo(),
        throwsA(isA<Exception>()),
      );
    });

    test('lanza excepcion cuando la respuesta no es un objeto JSON', () async {
      final mock = MockClient((request) async {
        return http.Response(jsonEncode(['array', 'no', 'object']), 200);
      });

      final repo = AppVersionRepository(client: mock);
      expect(
        () => repo.getAppVersionInfo(),
        throwsA(isA<Exception>()),
      );
    });

    test('acepta JSON con campos faltantes (todos quedan null)', () async {
      final mock = MockClient((request) async {
        return http.Response(jsonEncode({'minRequiredVersion': '2.0.0'}), 200);
      });

      final repo = AppVersionRepository(client: mock);
      final info = await repo.getAppVersionInfo();
      expect(info.minRequiredVersion, '2.0.0');
      expect(info.latestVersion, isNull);
      expect(info.androidStoreUrl, isNull);
      expect(info.iosStoreUrl, isNull);
      expect(info.message, isNull);
    });
  });
}
