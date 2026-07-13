import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatThreadScreen extends StatefulWidget {
  final String threadId;

  const ChatThreadScreen({super.key, required this.threadId});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final messageController = TextEditingController();
  bool isSending = false;

  Future<void> _sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => isSending = true);
    final threadRef = FirebaseFirestore.instance.collection('chat_threads').doc(widget.threadId);
    final threadSnapshot = await threadRef.get();
    final threadData = threadSnapshot.data();
    final waitingForReplyFrom = threadData?['waitingForReplyFrom'] as String?;

    if (waitingForReplyFrom != null && waitingForReplyFrom != uid) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for a reply before sending another message.')),
      );
      setState(() => isSending = false);
      return;
    }

    await threadRef.collection('messages').add({
      'senderId': uid,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final participants = List<String>.from(threadData?['participants'] ?? []);
    final nextWait = participants.firstWhere((participant) => participant != uid, orElse: () => uid);

    await threadRef.update({
      'lastMessage': content,
      'lastUpdated': FieldValue.serverTimestamp(),
      'unreadCounts': {
        for (final participant in participants)
          participant: participant == nextWait ? FieldValue.increment(1) : 0,
      },
      'waitingForReplyFrom': nextWait,
    });

    messageController.clear();
    if (!mounted) return;
    setState(() => isSending = false);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Conversation'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chat_threads')
                  .doc(widget.threadId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data();
                    final isMine = data['senderId'] == uid;
                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isMine ? theme.colorScheme.primary : theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          data['content'] ?? '',
                          style: TextStyle(
                            color: isMine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isSending ? null : _sendMessage,
                  child: isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
