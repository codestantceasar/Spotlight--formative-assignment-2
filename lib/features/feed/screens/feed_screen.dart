import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF051424),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feed_posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No posts yet. Create the first one!',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(
                    (0.75 * 255).round(),
                  ),
                  fontSize: 18,
                ),
              ),
            );
          }
          final posts = snapshot.data!.docs
              .map((doc) => doc.data()! as Map<String, dynamic>)
              .toList();
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 100, top: 16),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return FeedPostCard(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}

class FeedPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const FeedPostCard({super.key, required this.post});
  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  VideoPlayerController? _videoController;
  bool isVideoInitialized = false;
  bool videoError = false;
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant FeedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post['videoUrl'] != widget.post['videoUrl']) {
      _disposeVideo();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final videoUrl = widget.post['videoUrl'] as String?;
    if (videoUrl == null || videoUrl.isEmpty) {
      return;
    }
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    try {
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      if (!mounted) return;
      setState(() {
        isVideoInitialized = true;
        videoError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isVideoInitialized = false;
        videoError = true;
      });
    }
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    isVideoInitialized = false;
    videoError = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final author = widget.post['authorName'] as String? ?? 'Student';
    final caption = widget.post['caption'] as String? ?? '';
    final videoUrl = widget.post['videoUrl'] as String?;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F34),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF6C63FF),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.post['createdAt'] != null
                            ? 'New post'
                            : 'Just now',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(
                            (0.7 * 255).round(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (videoUrl != null && videoUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: isVideoInitialized
                    ? VideoPlayer(_videoController!)
                    : videoError
                    ? Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Text(
                            'Video unavailable',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.black,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              caption,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.favorite_border, color: theme.colorScheme.onSurface),
                const SizedBox(width: 12),
                Icon(
                  Icons.comment_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Icon(Icons.share_outlined, color: theme.colorScheme.onSurface),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
