class LeadModel {
  final String title;
  final String subreddit;
  final int intentScore;
  final String timeAgo;
  final String summary;

  LeadModel({
    required this.title,
    required this.subreddit,
    required this.intentScore,
    required this.timeAgo,
    required this.summary,
  });

  // Jab Reddit API se JSON aayega, ye use convert karega
  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      title: json['title'] ?? '',
      subreddit: json['subreddit'] ?? '',
      intentScore: json['score'] ?? 0,
      timeAgo: json['time'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}