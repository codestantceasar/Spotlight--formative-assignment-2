import 'package:flutter_riverpod/flutter_riverpod.dart';

final savedOpportunitiesProvider =
    StateNotifierProvider<SavedOpportunitiesNotifier, Set<String>>((ref) {
      return SavedOpportunitiesNotifier();
    });

class SavedOpportunitiesNotifier extends StateNotifier<Set<String>> {
  SavedOpportunitiesNotifier() : super({});

  void toggle(String opportunityId) {
    final updated = {...state};
    if (updated.contains(opportunityId)) {
      updated.remove(opportunityId);
    } else {
      updated.add(opportunityId);
    }
    state = updated;
  }

  bool contains(String opportunityId) => state.contains(opportunityId);
}
