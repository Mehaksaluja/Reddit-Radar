import 'package:flutter/material.dart';
import '../../data/models/lead_model.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback? onGenerateComment;
  final bool isGeneratingComment;

  const LeadCard({
    super.key,
    required this.lead,
    this.onGenerateComment,
    this.isGeneratingComment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Subreddit Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "r/${lead.subreddit}",
                    style: const TextStyle(
                      color: Color(0xFFFF4500), // Reddit Orange
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Intent Score Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: lead.intentScore >= 8
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Score: ${lead.intentScore}/10",
                    style: TextStyle(
                      color: lead.intentScore >= 8 ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Post Title
            Text(
              lead.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // AI Summary
            Text(
              lead.summary,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Time & User
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  lead.timeAgo,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isGeneratingComment ? null : onGenerateComment,
                icon: isGeneratingComment
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(isGeneratingComment ? 'Generating...' : 'Generate Comment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}