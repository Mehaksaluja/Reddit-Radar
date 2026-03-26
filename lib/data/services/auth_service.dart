import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  final String clientId = AppConfig.redditClientId;
  final String clientSecret = AppConfig.redditClientSecret;
  final String redirectUri = AppConfig.redditRedirectUri;

  Future<String?> loginWithReddit() async {
    if (clientId.isEmpty || redirectUri.isEmpty) {
      throw Exception('Reddit OAuth config missing. Pass REDDIT_CLIENT_ID and REDDIT_REDIRECT_URI via --dart-define.');
    }

    final state = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Construct the Reddit Auth URL
    final url = Uri.https('www.reddit.com', '/api/v1/authorize.compact', {
      'client_id': clientId,
      'response_type': 'code',
      'state': state,
      'redirect_uri': redirectUri,
      'duration': 'permanent',
      'scope': 'identity read submit',
    });

    try {
      // 2. Open browser for login
      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: "redditradar",
      );

      // 3. Extract the 'code' from the callback URL
      final callback = Uri.parse(result);
      final query = callback.queryParameters;
      final fragment = Uri.splitQueryString(callback.fragment.isEmpty ? '' : callback.fragment);
      final code = query['code'] ?? fragment['code'];
      final returnedState = query['state'] ?? fragment['state'];
      final oauthError = query['error'] ?? fragment['error'];
      if (oauthError != null && oauthError.isNotEmpty) {
        throw Exception('Reddit auth rejected: $oauthError');
      }
      if (returnedState != state) {
        throw Exception(
          'Invalid OAuth state. expected=$state got=$returnedState callback=$callback',
        );
      }

      if (code != null) {
        return await _getAccessToken(code);
      }
      throw Exception('No auth code found in callback: $callback');
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _getAccessToken(String code) async {
    final response = await _postAccessToken(
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
      },
      preferSecret: true,
    );

    if (response.statusCode == 200) {
      final token = await _saveAndReturnAccessToken(response.body);
      if (token == null || token.isEmpty) {
        throw Exception('Token missing in success response: ${response.body}');
      }
      return token;
    }

    throw Exception(_formatTokenError(response.statusCode, response.body));
  }

  Future<String?> getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('access_token');
    if (cached != null && cached.isNotEmpty) return cached;
    return _refreshAccessToken();
  }

  Future<String?> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final response = await _postAccessToken(
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
      preferSecret: true,
    );

    if (response.statusCode == 200) {
      return _saveAndReturnAccessToken(response.body);
    }
    return null;
  }

  Future<http.Response> _postAccessToken({
    required Map<String, String> body,
    required bool preferSecret,
  }) async {
    final attempts = <String>[];
    if (preferSecret && clientSecret.isNotEmpty) attempts.add(clientSecret);
    attempts.add('');
    if (!preferSecret && clientSecret.isNotEmpty) {
      attempts.add(clientSecret);
    }

    http.Response? last;
    for (final secret in attempts) {
      final response = await http.post(
        Uri.parse('https://www.reddit.com/api/v1/access_token'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
          'User-Agent': AppConfig.redditUserAgent,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      last = response;
      if (response.statusCode == 200) return response;
    }
    return last!;
  }

  Future<String?> _saveAndReturnAccessToken(String rawBody) async {
    final data = json.decode(rawBody) as Map<String, dynamic>;
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      await prefs.setString('access_token', accessToken);
    }
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    return accessToken;
  }

  String _formatTokenError(int statusCode, String body) {
    if (body.trim() == '{}') {
      return 'Reddit token exchange failed with empty response {}. '
          'Check Reddit app type and redirect URI. For mobile OAuth, use an "installed app" '
          'and redirect exactly as $redirectUri.';
    }
    return 'Token exchange failed: $statusCode $body';
  }
}