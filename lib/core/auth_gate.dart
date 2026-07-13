import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/home/screens/home_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/organization_home_screen.dart';

class AuthGate extends StatelessWidget {
  final ValueChanged<bool>? onThemeChanged;
  final bool isDarkMode;

  const AuthGate({super.key, this.onThemeChanged, this.isDarkMode = true});

  Future<String?> _getAccountType(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()?['accountType'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return LoginScreen(
            onThemeChanged: onThemeChanged,
            isDarkMode: isDarkMode,
          );
        }

        return FutureBuilder<String?>(
          future: _getAccountType(user.uid),
          builder: (context, accountSnapshot) {
            if (accountSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final accountType = accountSnapshot.data ?? 'creator';
            if (accountType == 'organization') {
              return OrganizationHomeScreen(
                onThemeChanged: onThemeChanged,
                isDarkMode: isDarkMode,
              );
            }

            return HomeScreen(
              onThemeChanged: onThemeChanged,
              isDarkMode: isDarkMode,
            );
          },
        );
      },
    );
  }
}
