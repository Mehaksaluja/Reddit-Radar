import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/nav/nav_cubit.dart';
import '../../logic/leads/leads_bloc.dart';
import '../../data/services/reddit_service.dart';
import '../widgets/lead_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // List of screens for the Bottom Nav
  final List<Widget> _screens = const [
    LeadsFeedView(), // Home/Leads Feed
    Center(child: Text("Search coming soon")), 
    Center(child: Text("My Replies coming soon")),
    Center(child: Text("Profile/Settings coming soon")),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavCubit()),
        BlocProvider(create: (context) => LeadsBloc(RedditService())..add(FetchLeads())),
      ],
      child: BlocBuilder<NavCubit, int>(
        builder: (context, currentIndex) {
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
            body: _screens[currentIndex],
            
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
                BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
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
  const LeadsFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeadsBloc, LeadsState>(
      builder: (context, state) {
        if (state is LeadsLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF4500)));
        } else if (state is LeadsLoaded) {
          return ListView.builder(
            itemCount: state.leads.length,
            itemBuilder: (context, index) {
              final lead = state.leads[index];
              return LeadCard(lead: {
                "title": lead.title,
                "sub": lead.subreddit,
                "score": lead.intentScore,
                "time": lead.timeAgo,
                "summary": lead.summary,
              });
            },
          );
        }
        return const Center(child: Text("Error loading leads"));
      },
    );
  }
}