import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_model.dart';
import 'auth_service.dart';
import '../config/app_config.dart';
import 'ai_service.dart';

class RedditService {
  final AuthService _authService;
  final AiService _aiService;

  RedditService({
    AuthService? authService,
    AiService? aiService,
  })  : _authService = authService ?? AuthService(),
        _aiService = aiService ?? AiService();

  Future<List<LeadModel>> fetchHotLeads({List<String> niches = const []}) async {
    final token = await _authService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please login again. Access token missing.');
    }

    final sourceSubs = niches.isEmpty ? ['entrepreneur', 'smallbusiness', 'startups'] : niches;
    final List<LeadModel> all = [];

    for (final sub in sourceSubs.take(5)) {
      final uri = Uri.https('oauth.reddit.com', '/r/$sub/new', {'limit': '15'});
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'User-Agent': AppConfig.redditUserAgent,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final children = (((data['data'] as Map<String, dynamic>?)?['children']) as List<dynamic>? ?? const []);
        all.addAll(
          children
              .whereType<Map<String, dynamic>>()
              .map(LeadModel.fromRedditJson)
              .where((e) => e.title.isNotEmpty),
        );
      }
    }

    all.sort((a, b) => b.intentScore.compareTo(a.intentScore));
    return all.take(40).toList();
  }

  Future<String> generateCommentForLead(LeadModel lead, String niche) {
    return _aiService.generateComment(lead, niche);
  }

  Future<void> postComment({
    required String parentThingId,
    required String text,
  }) async {
    final token = await _authService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please login again. Access token missing.');
    }

    final response = await http.post(
      Uri.https('oauth.reddit.com', '/api/comment'),
      headers: {
        'Authorization': 'Bearer $token',
        'User-Agent': AppConfig.redditUserAgent,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'api_type': 'json',
        'thing_id': parentThingId,
        'text': text,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Comment failed: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> submitPost({
    required String subreddit,
    required String title,
    required String text,
  }) async {
    final token = await _authService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please login again. Access token missing.');
    }

    final response = await http.post(
      Uri.https('oauth.reddit.com', '/api/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'User-Agent': AppConfig.redditUserAgent,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'api_type': 'json',
        'sr': subreddit,
        'kind': 'self',
        'title': title,
        'text': text,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Post submit failed: ${response.statusCode} ${response.body}');
    }
  }
}