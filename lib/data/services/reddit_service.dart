import '../models/lead_model.dart';

class RedditService {
  Future<List<LeadModel>> fetchHotLeads() async {
    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 2));

    // Fake Data as if coming from Reddit API
    return [
      LeadModel(
        title: "Looking for a Flutter developer for a US startup",
        subreddit: "forhire",
        intentScore: 9,
        timeAgo: "10m ago",
        summary: "Direct hiring intent for mobile development.",
      ),
      LeadModel(
        title: "How to automate Reddit posts with AI?",
        subreddit: "SaaS",
        intentScore: 7,
        timeAgo: "1h ago",
        summary: "User interested in automation tools.",
      ),
    ];
  }
}