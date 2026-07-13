import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final TextEditingController _controller = TextEditingController();

  bool isPosting = false;

  static const int maxLength = 500;

  Future<void> createPost() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before posting.')),
      );

      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('feed_posts').add({
        'authorId': user?.uid,

        'authorName': user?.displayName ?? user?.email ?? 'Creator',

        'caption': text,

        'videoUrl': '',

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your Spotlight is live ✨')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to post: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,

        elevation: 0,

        title: const Text(
          'Create Spotlight',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: ElevatedButton(
              onPressed: isPosting ? null : createPost,

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,

                foregroundColor: AppColors.background,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              child: isPosting
                  ? const SizedBox(
                      height: 18,

                      width: 18,

                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: AppColors.surface,

                  borderRadius: BorderRadius.circular(24),
                ),

                child: TextField(
                  controller: _controller,

                  maxLines: null,

                  maxLength: maxLength,

                  expands: true,

                  textAlignVertical: TextAlignVertical.top,

                  style: const TextStyle(color: AppColors.text, fontSize: 17),

                  decoration: const InputDecoration(
                    border: InputBorder.none,

                    hintText:
                        'Share your achievement, idea, project or story...',

                    hintStyle: TextStyle(color: AppColors.muted),

                    counterStyle: TextStyle(color: AppColors.muted),
                  ),

                  onChanged: (_) {
                    setState(() {});
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.surface,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.secondary),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Share your talent, progress, ideas or opportunities with the Spotlight community.',

                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
