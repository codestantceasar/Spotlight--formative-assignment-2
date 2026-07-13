import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:spotlight/features/feed/screens/feed_screen.dart';
import 'package:spotlight/features/chat/screens/chat_list_screen.dart';
import 'package:spotlight/features/splash/splash_screen.dart';

class OrganizationHomeScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;
  final bool isDarkMode;

  const OrganizationHomeScreen({
    super.key,
    this.onThemeChanged,
    this.isDarkMode = true,
  });

  @override
  State<OrganizationHomeScreen> createState() => _OrganizationHomeScreenState();
}

class _OrganizationHomeScreenState extends State<OrganizationHomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const _OrganizationFeed(),
    const _OrganizationDashboard(),
    const _OpportunityBoard(),
    const ChatListScreen(),
    const _OrganizationProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          "SPOTLIGHT ORG",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.cardColor,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withAlpha(
          (0.6 * 255).round(),
        ),
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Feed",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Create",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _OrganizationFeed extends StatelessWidget {
  const _OrganizationFeed();

  @override
  Widget build(BuildContext context) {
    return const FeedScreen();
  }
}

class _OrganizationDashboard extends StatelessWidget {
  const _OrganizationDashboard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Center(
        child: Text(
          'Please sign in to view your dashboard.',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      );
    }

    final activeJobsStream = FirebaseFirestore.instance
        .collection('opportunities')
        .where('createdBy', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots();

    final applicationsStream = FirebaseFirestore.instance
        .collection('job_applications')
        .where('organizationId', isEqualTo: uid)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: activeJobsStream,
      builder: (context, jobsSnapshot) {
        final activeJobs = jobsSnapshot.data?.docs ?? [];
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: applicationsStream,
          builder: (context, appsSnapshot) {
            final applications = appsSnapshot.data?.docs ?? [];
            final shortlistCount = applications.where((doc) {
              final status = doc.data()['status'] as String?;
              return status == 'shortlisted';
            }).length;
            final messageCount = applications.length;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Discover talent',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your org dashboard shows active roles, incoming applications, and shortlisted talent.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.7 * 255).round(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _InfoCard(
                  title: 'Active jobs',
                  value: activeJobs.length.toString(),
                  subtitle: 'Live postings',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Shortlisted creators',
                  value: shortlistCount.toString(),
                  subtitle: 'Talent ready for review',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'New enquiries',
                  value: messageCount.toString(),
                  subtitle: 'Application requests',
                ),
                const SizedBox(height: 24),
                Text(
                  'Active job listings',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (jobsSnapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (activeJobs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No active jobs yet. Create one from the Create tab.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(
                          (0.7 * 255).round(),
                        ),
                      ),
                    ),
                  )
                else
                  ...activeJobs.map((doc) {
                    final data = doc.data();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['role'] ?? 'Untitled role',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['company'] ?? '',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withAlpha(
                                (0.7 * 255).round(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withAlpha(
                                (0.65 * 255).round(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['reward'] ?? '',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Applications: ${applications.where((app) => app.data()['opportunityId'] == doc.id).length}',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    (0.7 * 255).round(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}

class _OpportunityBoard extends StatefulWidget {
  const _OpportunityBoard();

  @override
  State<_OpportunityBoard> createState() => _OpportunityBoardState();
}

class _OpportunityBoardState extends State<_OpportunityBoard> {
  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final rewardController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    companyController.dispose();
    roleController.dispose();
    rewardController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _postOpportunity() async {
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('opportunities').add({
        'company': companyController.text.trim(),
        'role': roleController.text.trim(),
        'reward': rewardController.text.trim(),
        'description': descriptionController.text.trim(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': Timestamp.now(),
        'isActive': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opportunity created successfully.')),
      );
      companyController.clear();
      roleController.clear();
      rewardController.clear();
      descriptionController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create opportunity: $e')),
      );
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Create Opportunity",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: companyController,
          decoration: const InputDecoration(labelText: "Company"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: roleController,
          decoration: const InputDecoration(labelText: "Role"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: rewardController,
          decoration: const InputDecoration(labelText: "Reward"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(labelText: "Description"),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _postOpportunity,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Send Opportunity"),
          ),
        ),
      ],
    );
  }
}

class _OrganizationProfile extends StatelessWidget {
  const _OrganizationProfile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: theme.colorScheme.primary,
          child: Icon(
            Icons.business,
            size: 34,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Bright Studios",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Hiring creators, storytellers, and social talent",
          style: TextStyle(
            color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
          ),
        ),
        const SizedBox(height: 20),
        _InfoCard(
          title: "Company Score",
          value: "92",
          subtitle: "Verified partner",
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text("Logout"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
