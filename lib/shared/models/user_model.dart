class UserModel {
  final String uid;
  final String name;
  final String email;
  final String accountType;
  final int spotlightScore;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.accountType,
    required this.spotlightScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'accountType': accountType,
      'spotlightScore': spotlightScore,
    };
  }
}
