import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:spotlight/features/feed/screens/feed_screen.dart';
import 'package:spotlight/features/home/screens/notification_screen.dart';
import 'package:spotlight/features/profile/screens/profile_screen.dart';
import 'package:spotlight/features/opportunities/screens/opportunities_screen.dart';
import 'package:spotlight/features/discover/screens/discover_screen.dart';
import 'package:spotlight/features/create/screens/create_screen.dart';
import '../../chat/screens/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;
  final bool isDarkMode;

  const HomeScreen({super.key, this.onThemeChanged, this.isDarkMode = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  bool _isOrganization = false;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!mounted) return;
    setState(() {
      _isOrganization = doc.data()?['accountType'] == 'organization';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const FeedScreen(),
      const DiscoverScreen(),
      if (!_isOrganization) const CreateScreen(),
      const ChatListScreen(),
      const OpportunitiesScreen(),
      ProfileScreen(
        onThemeChanged: widget.onThemeChanged,
        isDarkMode: widget.isDarkMode,
      ),
    ];

    final items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: "Feed",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: "Discover",
      ),
      if (!_isOrganization)
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: "Create",
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: "Chat",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.work_outline),
        activeIcon: Icon(Icons.work),
        label: "Jobs",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: "Profile",
      ),
    ];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          "SPOTLIGHT",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),

      body:
          pages[currentIndex < pages.length ? currentIndex : pages.length - 1],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.cardColor,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withAlpha(
          (0.6 * 255).round(),
        ),

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: items,
      ),
    );
  }
}
