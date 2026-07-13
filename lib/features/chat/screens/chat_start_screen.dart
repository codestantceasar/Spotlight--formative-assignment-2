import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_thread_screen.dart';

class ChatStartScreen extends StatefulWidget {
  const ChatStartScreen({super.key});

  @override
  State<ChatStartScreen> createState() => _ChatStartScreenState();
}

class _ChatStartScreenState extends State<ChatStartScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> _acceptedConnections() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('connections')
        .where('participants', arrayContains: uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  Future<void> _openThread(String otherUid, String title) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final threadsQuery = await FirebaseFirestore.instance
        .collection('chat_threads')
        .where('participants', arrayContains: currentUid)
        .get();

    QueryDocumentSnapshot<Map<String, dynamic>>? existingThread;
    for (final doc in threadsQuery.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.length == 2 && participants.contains(otherUid)) {
        existingThread = doc;
        break;
      }
    }

    if (existingThread != null) {
      if (!mounted) return;
      final threadId = existingThread.id;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatThreadScreen(threadId: threadId)),
      );
      return;
    }

    final newThread = await FirebaseFirestore.instance
        .collection('chat_threads')
        .add({
          'participants': [currentUid, otherUid],
          'title': title,
          'lastMessage': '',
          'lastUpdated': FieldValue.serverTimestamp(),
          'unreadCounts': {currentUid: 0, otherUid: 0},
          'waitingForReplyFrom': null,
        });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatThreadScreen(threadId: newThread.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('New chat'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _acceptedConnections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final connections = snapshot.data?.docs ?? [];
          if (connections.isEmpty) {
            return Center(
              child: Text(
                'No accepted contacts available yet. Connect with followers or organizations and wait for acceptance before messaging.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(
                    (0.7 * 255).round(),
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            itemCount: connections.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final connection = connections[index].data();
              final participants = List<String>.from(
                connection['participants'] ?? [],
              );
              final uid = FirebaseAuth.instance.currentUser?.uid;
              final otherId = participants.firstWhere(
                (id) => id != uid,
                orElse: () => '',
              );
              final name =
                  connection['displayName'] ?? connection['title'] ?? 'Contact';
              final accountType = connection['accountType'] ?? 'Contact';

              return ListTile(
                title: Text(
                  name,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                subtitle: Text(
                  accountType,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.7 * 255).round(),
                    ),
                  ),
                ),
                trailing: const Icon(Icons.chat_bubble_outline),
                onTap: otherId.isNotEmpty
                    ? () => _openThread(otherId, name)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
