import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;

  const UserProfileScreen({super.key, required this.uid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;

  Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _postsStream() {
    return FirebaseFirestore.instance
        .collection('feed_posts')
        .where('authorId', isEqualTo: widget.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _connectionStream() {
    return FirebaseFirestore.instance
        .collection('connections')
        .where('participants', arrayContains: currentUid)
        .snapshots();
  }

  Future<void> connect() async {
    if (currentUid == null) return;

    await FirebaseFirestore.instance.collection('connections').add({
      'participants': [currentUid, widget.uid],

      'createdBy': currentUid,

      'status': 'accepted',

      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Connected successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,

        elevation: 0,

        title: const Text('Profile'),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _profileStream(),

        builder: (context, profileSnapshot) {
          if (!profileSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = profileSnapshot.data!.data() ?? {};

          final name = data['name'] ?? 'Unknown';

          final type = data['accountType'] ?? 'creator';

          final bio = data['bio'] ?? '';

          final score = data['spotlightScore'] ?? 0;

          final skills =
              (data['skills'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _connectionStream(),

            builder: (context, connectionSnapshot) {
              bool connected = false;

              if (connectionSnapshot.hasData) {
                for (final doc in connectionSnapshot.data!.docs) {
                  final users = List<String>.from(doc['participants'] ?? []);

                  if (users.contains(widget.uid)) {
                    connected = true;
                  }
                }
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _postsStream(),

                builder: (context, postSnapshot) {
                  final posts = postSnapshot.data?.docs ?? [];

                  return ListView(
                    padding: const EdgeInsets.all(20),

                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,

                          backgroundColor: theme.colorScheme.primary,

                          child: Icon(
                            type == 'organization'
                                ? Icons.business
                                : Icons.person,

                            size: 50,

                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Center(
                        child: Text(
                          name,

                          style: const TextStyle(
                            fontSize: 26,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Center(
                        child: Text(
                          type == 'organization' ? 'Organization' : 'Creator',

                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: theme.cardColor,

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Column(
                          children: [
                            const Text(
                              'Spotlight Score',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              score.toString(),

                              style: TextStyle(
                                fontSize: 32,

                                color: theme.colorScheme.primary,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: connected ? null : connect,

                              child: Text(connected ? 'Connected' : 'Connect'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},

                              child: const Text('Message'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'About',

                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 8),

                      Text(bio),

                      const SizedBox(height: 20),

                      Text(
                        'Skills',

                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,

                        children: skills
                            .map((skill) => Chip(label: Text(skill)))
                            .toList(),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'Posts',

                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      const SizedBox(height: 15),

                      GridView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: posts.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,

                              crossAxisSpacing: 8,

                              mainAxisSpacing: 8,
                            ),

                        itemBuilder: (context, index) {
                          final post = posts[index].data();

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: Center(
                              child: Text(
                                post['caption'] ?? '',

                                maxLines: 3,

                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
