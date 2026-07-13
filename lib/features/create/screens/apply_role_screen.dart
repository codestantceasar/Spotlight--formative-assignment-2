import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplyRoleScreen extends StatefulWidget {
  final String role;
  final String company;
  final String opportunityId;
  final String organizationId;

  const ApplyRoleScreen({
    super.key,
    required this.role,
    required this.company,
    required this.opportunityId,
    required this.organizationId,
  });

  @override
  State<ApplyRoleScreen> createState() => _ApplyRoleScreenState();
}

class _ApplyRoleScreenState extends State<ApplyRoleScreen> {
  final introController = TextEditingController();
  final experienceController = TextEditingController();
  final portfolioController = TextEditingController();
  final noteController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitApplication() async {
    final intro = introController.text.trim();
    final experience = experienceController.text.trim();
    final portfolio = portfolioController.text.trim();
    final note = noteController.text.trim();

    if (intro.isEmpty || experience.isEmpty || portfolio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the required fields.'),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('job_applications').add({
        'applicantId': user?.uid,
        'applicantName': user?.displayName ?? 'Student',
        'role': widget.role,
        'company': widget.company,
        'opportunityId': widget.opportunityId,
        'organizationId': widget.organizationId,
        'status': 'submitted',
        'intro': intro,
        'experience': experience,
        'portfolio': portfolio,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully.'),
        ),
      );
      introController.clear();
      experienceController.clear();
      portfolioController.clear();
      noteController.clear();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to submit application: $error')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    introController.dispose();
    experienceController.dispose();
    portfolioController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Apply for a role'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${widget.company} • ${widget.role}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Use this form to send a strong application and market your skills.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha((0.72 * 255).round()),
              ),
            ),
            const SizedBox(height: 20),
            _buildField(
              context,
              label: 'Short intro',
              child: TextField(
                controller: introController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Story-driven creator with strong editing skills',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              context,
              label: 'Experience',
              child: TextField(
                controller: experienceController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Share your past projects or achievements',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              context,
              label: 'Portfolio or link',
              child: TextField(
                controller: portfolioController,
                decoration: const InputDecoration(
                  hintText: 'https://yourportfolio.com',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              context,
              label: 'Why you would be a great fit',
              child: TextField(
                controller: noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add a quick pitch for the company',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isSubmitting ? null : submitApplication,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(isSubmitting ? 'Submitting...' : 'Submit application'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
