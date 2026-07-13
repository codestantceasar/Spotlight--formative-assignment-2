import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String accountType,
    required String bio,
    String? school,
    String? major,
    String? year,
    String? industry,
    String? tagline,
    List<String>? skills,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userData = {
      'uid': credential.user!.uid,
      'name': name,
      'email': email,
      'accountType': accountType,
      'bio': bio,
      'spotlightScore': 0,
      'createdAt': Timestamp.now(),
    };

    if (accountType == 'creator') {
      userData['school'] = school ?? '';
      userData['major'] = major ?? '';
      if (year != null && year.isNotEmpty) {
        userData['year'] = year;
      }
    } else {
      userData['industry'] = industry ?? '';
      userData['tagline'] = tagline ?? '';
    }

    // Persist skills if provided
    if (skills != null && skills.isNotEmpty) {
      userData['skills'] = skills;
    } else {
      userData['skills'] = <String>[];
    }

    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(userData);
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
