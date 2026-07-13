// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spotlight/features/auth/screens/register_screen.dart';
import 'package:spotlight/features/profile/screens/profile_screen.dart';
import 'package:spotlight/features/splash/splash_screen.dart';

void main() {
  testWidgets('RegisterScreen shows its form UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    expect(find.text('SPOTLIGHT'), findsOneWidget);
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('Theme toggle appears only on the profile screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SplashScreen(isDarkMode: true)),
      ),
    );
    expect(find.text('Dark mode'), findsNothing);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfileScreen(isDarkMode: true)),
      ),
    );
    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('Profile screen shows the applications section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfileScreen(isDarkMode: true)),
      ),
    );

    expect(find.text('My Applications'), findsOneWidget);
  });
}
