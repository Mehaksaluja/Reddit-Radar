import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/lead_model.dart';

class AiService {
  Future<String> generateComment(LeadModel lead, String niche) async {
    final prompt =
        'Write a short, helpful Reddit comment for this post.\n'
        'Niche: $niche\n'
        'Subreddit: r/${lead.subreddit}\n'
        'Title: ${lead.title}\n'
        'Summary: ${lead.summary}\n'
        'Rules: max 90 words, no emojis, no hashtags, no hard selling, sound human.';
    return _generateText(prompt, fallback: _fallbackComment(lead));
  }

  Future<String> generatePostBody({
    required String niche,
    required String goal,
    required String tone,
  }) async {
    final prompt =
        'Generate a Reddit post body for a business audience.\n'
        'Niche: $niche\n'
        'Goal: $goal\n'
        'Tone: $tone\n'
        'Rules: 120-180 words, conversational, clear CTA at end, no buzzword spam.';
    return _generateText(
      prompt,
      fallback:
          'Hi everyone, I am working in $niche and trying to improve around $goal. '
          'I would love practical advice from people who have done this recently. '
          'What has worked for you, what did not, and what would you do first if you were starting today? '
          'Thanks in advance.',
    );
  }

  Future<String> _generateText(String prompt, {required String fallback}) async {
    if (AppConfig.openAiApiKey.isEmpty) {
      return fallback;
    }

    final uri = Uri.parse('${AppConfig.openAiBaseUrl}/chat/completions');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': AppConfig.openAiModel,
        'messages': [
          {'role': 'system', 'content': 'You write high-quality Reddit content.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>? ?? const [];
      if (choices.isNotEmpty) {
        final message = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    }

    return fallback;
  }

  String _fallbackComment(LeadModel lead) {
    return 'Great question. Based on what you shared in "${lead.title}", '
        'I would start with one small repeatable workflow, measure it for a week, '
        'and then scale only the parts that consistently save time or improve outcomes.';
  }
}
