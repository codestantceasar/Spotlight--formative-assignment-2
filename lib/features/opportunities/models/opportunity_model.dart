class OpportunityModel {
  final String id;
  final String company;
  final String role;
  final String reward;
  final String description;

  OpportunityModel({
    required this.id,
    required this.company,
    required this.role,
    required this.reward,
    required this.description,
  });

  factory OpportunityModel.fromMap(String id, Map<String, dynamic> data) {
    return OpportunityModel(
      id: id,
      company: data['company'] ?? '',
      role: data['role'] ?? '',
      reward: data['reward'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
