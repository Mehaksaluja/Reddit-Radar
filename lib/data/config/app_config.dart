import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get redditClientId => _read('REDDIT_CLIENT_ID');
  static String get redditClientSecret => _read('REDDIT_CLIENT_SECRET');
  static String get redditRedirectUri => _read(
        'REDDIT_REDIRECT_URI',
        fallback: 'redditradar://callback',
      );
  static String get redditUserAgent => _read(
        'REDDIT_USER_AGENT',
        fallback: 'android:com.redditradar.app:v1.0.0 (by /u/your_username)',
      );

  static String get openAiApiKey => _read('OPENAI_API_KEY', envFallbackKey: 'GEMINI_API_KEY');
  static String get openAiModel => _read('OPENAI_MODEL', fallback: 'gpt-4o-mini');
  static String get openAiBaseUrl => _read('OPENAI_BASE_URL', fallback: 'https://api.openai.com/v1');

  static String _read(
    String key, {
    String fallback = '',
    String? envFallbackKey,
  }) {
    final fromDotEnv = dotenv.maybeGet(key);
    if (fromDotEnv != null && fromDotEnv.trim().isNotEmpty) {
      return _sanitize(fromDotEnv);
    }

    if (envFallbackKey != null) {
      final secondary = dotenv.maybeGet(envFallbackKey);
      if (secondary != null && secondary.trim().isNotEmpty) {
        return _sanitize(secondary);
      }
    }

    // Preserve --dart-define support while prioritizing .env values.
    if (key == 'REDDIT_CLIENT_ID') {
      final v = const String.fromEnvironment('REDDIT_CLIENT_ID', defaultValue: '');
      if (v.isNotEmpty) return _sanitize(v);
    }
    if (key == 'REDDIT_CLIENT_SECRET') {
      final v = const String.fromEnvironment('REDDIT_CLIENT_SECRET', defaultValue: '');
      if (v.isNotEmpty) return _sanitize(v);
    }
    if (key == 'REDDIT_REDIRECT_URI') {
      final v = const String.fromEnvironment('REDDIT_REDIRECT_URI', defaultValue: '');
      if (v.isNotEmpty) return _sanitize(v);
    }
    if (key == 'REDDIT_USER_AGENT') {
      final v = const String.fromEnvironment('REDDIT_USER_AGENT', defaultValue: '');
      if (v.isNotEmpty) return _sanitize(v);
    }
    if (key == 'OPENAI_API_KEY') {
      final v = const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
      if (v.isNotEmpty) return _sanitize(v);
    }
    if (key == 'OPENAI_MODEL') {
      final v = const String.fromEnvironment('OPENAI_MODEL', defaultValue: '');
      if (v.isNotEmpty) return _sanitize(v);
    }
    if (key == 'OPENAI_BASE_URL') {
      final v = const String.fromEnvironment('OPENAI_BASE_URL', defaultValue: '');
      if (v.isNotEmpty) return _sanitize(v);
    }
    return fallback;
  }

  static String _sanitize(String value) {
    final v = value.trim();
    if (v.length >= 2 &&
        ((v.startsWith('"') && v.endsWith('"')) ||
            (v.startsWith("'") && v.endsWith("'")))) {
      return v.substring(1, v.length - 1).trim();
    }
    return v;
  }
}
