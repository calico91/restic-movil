import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static const String _envAppApiKey = String.fromEnvironment(
    'APP_API_KEY',
    defaultValue: '',
  );

  static String get appApiKey {
    if (_envAppApiKey.isNotEmpty) return _envAppApiKey;
    return dotenv.env['APP_API_KEY'] ?? '';
  }
}
