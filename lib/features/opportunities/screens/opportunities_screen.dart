import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/saved_opportunities_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../create/screens/apply_role_screen.dart';
import 'add_opportunity_screen.dart';

class OpportunitiesScreen extends ConsumerWidget {
  const OpportunitiesScreen({super.key});

  Future<bool> isOrganization() async {
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final saved = ref.watch(savedOpportunitiesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,

        child: Icon(Icons.add, color: AppColors.darkText),

        onPressed: () {
          Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const AddOpportunityScreen()),
          );
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('opportunities')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final opportunities = snapshot.data?.docs ?? [];

          if (opportunities.isEmpty) {
            return Center(
              child: Text(
                'No opportunities available yet',

                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),

            itemCount: opportunities.length,

            itemBuilder: (context, index) {
              final doc = opportunities[index];

              final data = doc.data() as Map<String, dynamic>;

              final id = doc.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: theme.cardColor,

                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,

                          child: Icon(
                            Icons.business,

                            color: AppColors.darkText,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                data['company'] ?? 'Organization',

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,

                                  fontSize: 18,
                                ),
                              ),

                              Text(
                                data['role'] ?? 'Opportunity',

                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            ref
                                .read(savedOpportunitiesProvider.notifier)
                                .toggle(id);
                          },

                          icon: Icon(
                            saved.contains(id)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      data['description'] ?? '',

                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,

                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(40),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        data['reward'] ?? 'Reward',

                        style: const TextStyle(
                          color: Colors.green,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => ApplyRoleScreen(
                                company: data['company'] ?? '',

                                role: data['role'] ?? '',

                                opportunityId: id,

                                organizationId: data['createdBy'] ?? '',
                              ),
                            ),
                          );
                        },

                        child: const Text('Apply Now'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
