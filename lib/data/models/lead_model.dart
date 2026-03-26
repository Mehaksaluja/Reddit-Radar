class LeadModel {
  final String id;
  final String title;
  final String subreddit;
  final String selfText;
  final int intentScore;
  final String timeAgo;
  final String summary;

  LeadModel({
    required this.id,
    required this.title,
    required this.subreddit,
    required this.selfText,
    required this.intentScore,
    required this.timeAgo,
    required this.summary,
  });

  factory LeadModel.fromRedditJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final title = (data['title'] as String? ?? '').trim();
    final selfText = (data['selftext'] as String? ?? '').trim();
    final createdUtc = (data['created_utc'] as num?)?.toInt();

    return LeadModel(
      id: (data['name'] as String? ?? '').trim(),
      title: title,
      subreddit: (data['subreddit'] as String? ?? '').trim(),
      selfText: selfText,
      intentScore: _scoreIntent(title, selfText),
      timeAgo: _timeAgoFromUnix(createdUtc),
      summary: _buildSummary(title, selfText),
    );
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subreddit: json['subreddit'] ?? '',
      selfText: json['self_text'] ?? '',
      intentScore: json['score'] ?? 0,
      timeAgo: json['time'] ?? '',
      summary: json['summary'] ?? '',
    );
  }

  static int _scoreIntent(String title, String body) {
    final text = '${title.toLowerCase()} ${body.toLowerCase()}';
    final buyingSignals = [
      'looking for',
      'need',
      'hire',
      'agency',
      'tool',
      'software',
      'recommend',
      'best way',
      'struggling with',
      'help',
    ];
    final scoreBoost = buyingSignals.where(text.contains).length;
    final score = 4 + scoreBoost;
    return score.clamp(1, 10);
  }

  static String _buildSummary(String title, String body) {
    final source = body.isNotEmpty ? body : title;
    if (source.length <= 120) return source;
    return '${source.substring(0, 117)}...';
  }

  static String _timeAgoFromUnix(int? unixSeconds) {
    if (unixSeconds == null) return 'recently';
    final created = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000, isUtc: true);
    final diff = DateTime.now().toUtc().difference(created);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}