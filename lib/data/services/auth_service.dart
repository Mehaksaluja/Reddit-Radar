import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String clientId = "YOUR_CLIENT_ID"; // Reddit se jo mila tha
  final String clientSecret = "YOUR_CLIENT_SECRET"; 
  final String redirectUri = "redditradar://callback"; // Isse manifest mein bhi dalna hoga

  Future<String?> loginWithReddit() async {
    // 1. Construct the Reddit Auth URL
    final url = Uri.https('www.reddit.com', '/api/v1/authorize', {
      'client_id': clientId,
      'response_type': 'code',
      'state': 'random_state_string',
      'redirect_uri': redirectUri,
      'duration': 'permanent',
      'scope': 'identity read submit', // Humein post karne aur padhne ki permission chahiye
    });

    try {
      // 2. Open browser for login
      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: "redditradar",
      );

      // 3. Extract the 'code' from the callback URL
      final code = Uri.parse(result).queryParameters['code'];

      if (code != null) {
        // 4. Exchange 'code' for an 'Access Token'
        return await _getAccessToken(code);
      }
    } catch (e) {
      print("Auth Error: $e");
    }
    return null;
  }

  Future<String?> _getAccessToken(String code) async {
    final response = await http.post(
      Uri.parse('https://www.reddit.com/api/v1/access_token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token']; // Ye token hume real data dega
    }
    return null;
  }
}