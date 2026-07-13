import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_start_screen.dart';
import 'chat_thread_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> chatStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return FirebaseFirestore.instance
        .collection('chat_threads')
        .where('participants', arrayContains: uid)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,

        elevation: 0,

        title: const Text(
          'Messages',

          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const ChatStartScreen()),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: chatStream(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data?.docs ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.chat_bubble_outline,

                    size: 70,

                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'No conversations yet',

                    style: TextStyle(
                      color: theme.colorScheme.onSurface,

                      fontSize: 20,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Connect with creators and organizations to start chatting.',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: chats.length,

            itemBuilder: (context, index) {
              final chat = chats[index];

              final data = chat.data();

              final title = data['title'] ?? 'Conversation';

              final lastMessage = data['lastMessage'] ?? 'Start conversation';

              final uid = FirebaseAuth.instance.currentUser?.uid;

              final unread = data['unreadCounts']?[uid] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),

                decoration: BoxDecoration(
                  color: theme.cardColor,

                  borderRadius: BorderRadius.circular(20),
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,

                    vertical: 8,
                  ),

                  leading: CircleAvatar(
                    radius: 26,

                    backgroundColor: theme.colorScheme.primary,

                    child: Icon(
                      Icons.person,

                      color: theme.colorScheme.onPrimary,
                    ),
                  ),

                  title: Text(
                    title,

                    style: TextStyle(
                      color: theme.colorScheme.onSurface,

                      fontWeight: FontWeight.bold,

                      fontSize: 16,
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),

                    child: Text(
                      lastMessage,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  ),

                  trailing: unread > 0
                      ? CircleAvatar(
                          radius: 12,

                          backgroundColor: theme.colorScheme.primary,

                          child: Text(
                            unread.toString(),

                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,

                              fontSize: 12,
                            ),
                          ),
                        )
                      : const Icon(Icons.chevron_right),

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => ChatThreadScreen(threadId: chat.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
