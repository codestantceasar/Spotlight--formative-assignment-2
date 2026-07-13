import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddOpportunityScreen extends StatefulWidget {
  const AddOpportunityScreen({super.key});

  @override
  State<AddOpportunityScreen> createState() => _AddOpportunityScreenState();
}

class _AddOpportunityScreenState extends State<AddOpportunityScreen> {
  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final rewardController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> postOpportunity() async {
    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    final createdBy = user?.uid;
    await FirebaseFirestore.instance.collection('opportunities').add({
      'company': companyController.text.trim(),
      'role': roleController.text.trim(),
      'reward': rewardController.text.trim(),
      'description': descriptionController.text.trim(),
      'createdBy': createdBy,
      'createdAt': Timestamp.now(),
      'isActive': true,
    });

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text("Post Opportunity"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: "Company"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: "Role"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: rewardController,
              decoration: const InputDecoration(labelText: "Reward"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: isLoading ? null : postOpportunity,

              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Post Opportunity"),
            ),
          ],
        ),
      ),
    );
  }
}
