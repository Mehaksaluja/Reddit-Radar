import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/nav/nav_cubit.dart';
import '../../logic/leads/leads_bloc.dart';
import '../../data/models/lead_model.dart';
import '../../data/services/reddit_service.dart';
import '../widgets/lead_card.dart';
import 'automation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final redditService = RedditService();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavCubit()),
        BlocProvider(create: (context) => LeadsBloc(redditService)..add(FetchLeads())),
      ],
      child: BlocBuilder<NavCubit, int>(
        builder: (context, currentIndex) {
          final screens = [
            LeadsFeedView(redditService: redditService),
            const AutomationScreen(),
            const Center(child: Text("My Replies coming soon")),
            const Center(child: Text("Profile/Settings coming soon")),
          ];

          return Scaffold(
            appBar: AppBar(
              title: const Text("REDDIT RADAR"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<LeadsBloc>().add(FetchLeads()),
                ),
              ],
            ),
            // Current Screen based on Bottom Nav Index
            body: screens[currentIndex],
            
            // The Reddit-style Bottom Navigation Bar
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => context.read<NavCubit>().updateIndex(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF1A1A1B),
              selectedItemColor: const Color(0xFFFF4500), // Reddit Orange
              unselectedItemColor: Colors.white54,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.radar), label: "Radar"),
                BottomNavigationBarItem(icon: Icon(Icons.auto_mode), label: "Auto Post"),
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Replies"),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Leads Feed View separated to keep code clean
class LeadsFeedView extends StatelessWidget {
  final RedditService redditService;
  const LeadsFeedView({super.key, required this.redditService});

  @override
  Widget build(BuildContext context) {
    return _LeadsFeedViewBody(redditService: redditService);
  }
}

class _LeadsFeedViewBody extends StatefulWidget {
  final RedditService redditService;
  const _LeadsFeedViewBody({required this.redditService});

  @override
  State<_LeadsFeedViewBody> createState() => _LeadsFeedViewBodyState();
}

class _LeadsFeedViewBodyState extends State<_LeadsFeedViewBody> {
  final _nicheCtrl = TextEditingController(text: 'entrepreneur,smallbusiness,startups');
  final Set<String> _loadingIds = {};

  @override
  void dispose() {
    _nicheCtrl.dispose();
    super.dispose();
  }

  List<String> _niches() => _nicheCtrl.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _handleGenerateComment(LeadModel lead) async {
    setState(() => _loadingIds.add(lead.id));
    try {
      final niche = _niches().isEmpty ? 'business' : _niches().first;
      final comment = await widget.redditService.generateCommentForLead(lead, niche);
      if (!mounted) return;
      final posted = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('AI Comment Draft'),
              content: SingleChildScrollView(child: Text(comment)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Close')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Post Comment')),
              ],
            ),
          ) ??
          false;

      if (posted) {
        await widget.redditService.postComment(parentThingId: lead.id, text: comment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment posted successfully.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment flow failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingIds.remove(lead.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nicheCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Niches/subreddits comma separated',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => context.read<LeadsBloc>().add(FetchLeads(niches: _niches())),
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<LeadsBloc, LeadsState>(
            builder: (context, state) {
              if (state is LeadsLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF4500)));
              } else if (state is LeadsLoaded) {
                if (state.leads.isEmpty) {
                  return const Center(child: Text('No matching posts found.'));
                }
                return ListView.builder(
                  itemCount: state.leads.length,
                  itemBuilder: (context, index) {
                    final lead = state.leads[index];
                    return LeadCard(
                      lead: lead,
                      isGeneratingComment: _loadingIds.contains(lead.id),
                      onGenerateComment: () => _handleGenerateComment(lead),
                    );
                  },
                );
              } else if (state is LeadsError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text("Error loading leads"));
            },
          ),
        ),
      ],
    );
  }
}