import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/screens/user_profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> connectionsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('connections')
        .where('participants', arrayContains: uid)
        .snapshots();
  }

  Future<void> connectUser(String targetUid, String name, String type) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) return;

    await FirebaseFirestore.instance.collection('connections').add({
      'participants': [currentUid, targetUid],

      'createdBy': currentUid,

      'status': 'accepted',

      'createdAt': FieldValue.serverTimestamp(),

      'name': name,

      'accountType': type,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Connected successfully')));
  }

  bool matchesSearch(Map<String, dynamic> data) {
    if (searchQuery.isEmpty) {
      return true;
    }

    final name = data['name']?.toString().toLowerCase() ?? '';

    final type = data['accountType']?.toString().toLowerCase() ?? '';

    return name.contains(searchQuery) || type.contains(searchQuery);
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Please login first'));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: connectionsStream(uid),

        builder: (context, connectionSnapshot) {
          final connectedUsers = <String>{};

          if (connectionSnapshot.hasData) {
            for (final doc in connectionSnapshot.data!.docs) {
              final users = List<String>.from(doc['participants'] ?? []);

              for (final user in users) {
                if (user != uid) {
                  connectedUsers.add(user);
                }
              }
            }
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: usersStream(),

            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = userSnapshot.data!.docs.where((doc) {
                final data = doc.data();

                final userId = data['uid'] ?? doc.id;

                return userId != uid && matchesSearch(data);
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(20),

                children: [
                  Text(
                    'Discover',

                    style: TextStyle(
                      color: theme.colorScheme.onSurface,

                      fontSize: 32,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Find creators, startups and opportunities',

                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: searchController,

                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },

                    decoration: InputDecoration(
                      hintText: 'Search creators...',

                      prefixIcon: Icon(
                        Icons.search,

                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  ...users.map((doc) {
                    final data = doc.data();

                    final targetUid = data['uid'] ?? doc.id;

                    final name = data['name'] ?? 'Unknown';

                    final type = data['accountType'] ?? 'creator';

                    final connected = connectedUsers.contains(targetUid);

                    final skills =
                        (data['skills'] as List<dynamic>?)
                            ?.take(3)
                            .map((e) => e.toString())
                            .toList() ??
                        [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: theme.cardColor,

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,

                            leading: CircleAvatar(
                              radius: 28,

                              backgroundColor: AppColors.primary,

                              child: Icon(
                                type == 'organization'
                                    ? Icons.business
                                    : Icons.person,

                                color: AppColors.darkText,
                              ),
                            ),

                            title: Text(
                              name,

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,

                                fontSize: 18,
                              ),
                            ),

                            subtitle: Text(
                              type == 'organization'
                                  ? 'Organization'
                                  : 'Creator',
                            ),

                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) =>
                                      UserProfileScreen(uid: targetUid),
                                ),
                              );
                            },
                          ),

                          if (skills.isNotEmpty)
                            Wrap(
                              spacing: 8,

                              children: skills
                                  .map((skill) => Chip(label: Text(skill)))
                                  .toList(),
                            ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(
                              onPressed: connected
                                  ? null
                                  : () {
                                      connectUser(targetUid, name, type);
                                    },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: connected
                                    ? AppColors.success
                                    : AppColors.primary,

                                foregroundColor: AppColors.darkText,
                              ),

                              child: Text(connected ? 'Connected' : 'Connect'),
                            ),
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
      ),
    );
  }
}
