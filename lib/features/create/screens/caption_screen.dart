import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CaptionScreen extends StatefulWidget {
  final String imagePath;

  const CaptionScreen({super.key, required this.imagePath});

  @override
  State<CaptionScreen> createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  final captionController = TextEditingController();

  bool uploading = false;

  double progress = 0;

  Future<void> uploadPost() async {
    final caption = captionController.text.trim();

    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a caption before posting.')),
      );

      return;
    }

    setState(() {
      uploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      final file = File(widget.imagePath);

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final storageRef = FirebaseStorage.instance.ref().child(
        'posts/$fileName.jpg',
      );

      final uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((snapshot) {
        setState(() {
          progress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      final snapshot = await uploadTask;

      final imageUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('feed_posts').add({
        'authorId': user?.uid,

        'authorName': user?.displayName ?? user?.email ?? 'Creator',

        'caption': caption,

        'imageUrl': imageUrl,

        'videoUrl': '',

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your Spotlight is live ✨')));

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          uploading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    captionController.dispose();

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
          'Add Caption',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),

                child: Image.file(
                  File(widget.imagePath),

                  width: double.infinity,

                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.surface,

                borderRadius: BorderRadius.circular(20),
              ),

              child: TextField(
                controller: captionController,

                maxLines: 4,

                style: const TextStyle(color: AppColors.text),

                decoration: const InputDecoration(
                  border: InputBorder.none,

                  hintText: 'Write a caption...',

                  hintStyle: TextStyle(color: AppColors.muted),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (uploading) ...[
              LinearProgressIndicator(value: progress),

              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: uploading ? null : uploadPost,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,

                  foregroundColor: AppColors.background,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: uploading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Post Spotlight',

                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
