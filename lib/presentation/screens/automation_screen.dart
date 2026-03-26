import 'package:flutter/material.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/reddit_service.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  final _subredditCtrl = TextEditingController(text: 'entrepreneur');
  final _titleCtrl = TextEditingController();
  final _goalCtrl = TextEditingController(text: 'get practical feedback');
  final _toneCtrl = TextEditingController(text: 'helpful and humble');
  final _bodyCtrl = TextEditingController();
  final _aiService = AiService();
  final _redditService = RedditService();
  bool _loading = false;

  @override
  void dispose() {
    _subredditCtrl.dispose();
    _titleCtrl.dispose();
    _goalCtrl.dispose();
    _toneCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateBody() async {
    setState(() => _loading = true);
    try {
      final text = await _aiService.generatePostBody(
        niche: _subredditCtrl.text.trim(),
        goal: _goalCtrl.text.trim(),
        tone: _toneCtrl.text.trim(),
      );
      _bodyCtrl.text = text;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _postNow() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add title and post body first.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _redditService.submitPost(
        subreddit: _subredditCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        text: _bodyCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published to Reddit.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _subredditCtrl,
          decoration: const InputDecoration(labelText: 'Target subreddit (without r/)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Post title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _goalCtrl,
          decoration: const InputDecoration(labelText: 'Goal'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _toneCtrl,
          decoration: const InputDecoration(labelText: 'Tone'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bodyCtrl,
          minLines: 6,
          maxLines: 12,
          decoration: const InputDecoration(labelText: 'Post body'),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: _loading ? null : _generateBody,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate with AI'),
            ),
            ElevatedButton.icon(
              onPressed: _loading ? null : _postNow,
              icon: const Icon(Icons.send),
              label: const Text('Post to Reddit'),
            ),
          ],
        ),
      ],
    );
  }
}
