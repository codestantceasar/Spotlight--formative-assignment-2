import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/spotlight_button.dart';
import '../../../core/widgets/account_type_card.dart';

import '../repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  final ValueChanged<bool>? onThemeChanged;
  final bool isDarkMode;

  const RegisterScreen({
    super.key,

    this.onThemeChanged,

    this.isDarkMode = true,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final schoolController = TextEditingController();

  final majorController = TextEditingController();

  final yearController = TextEditingController();

  final skillsController = TextEditingController();

  final industryController = TextEditingController();

  final taglineController = TextEditingController();

  String accountType = 'creator';

  bool loading = false;

  final AuthRepository auth = AuthRepository();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    schoolController.dispose();
    majorController.dispose();
    yearController.dispose();

    skillsController.dispose();

    industryController.dispose();
    taglineController.dispose();

    super.dispose();
  }

  Future<void> register() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMessage('Please fill name, email and password');

      setState(() {
        loading = false;
      });

      return;
    }

    String bio;

    if (accountType == 'creator') {
      if (schoolController.text.trim().isEmpty ||
          majorController.text.trim().isEmpty) {
        showMessage('Add your school and major');

        setState(() {
          loading = false;
        });

        return;
      }

      bio =
          '${nameController.text.trim()} is studying ${majorController.text.trim()} at ${schoolController.text.trim()}';
    } else {
      bio = '${nameController.text.trim()} — ${taglineController.text.trim()}';
    }

    final skills = skillsController.text.trim().isEmpty
        ? <String>[]
        : skillsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

    try {
      await auth.register(
        name: nameController.text.trim(),

        email: emailController.text.trim(),

        password: passwordController.text.trim(),

        accountType: accountType,

        bio: bio,

        school: accountType == 'creator' ? schoolController.text.trim() : null,

        major: accountType == 'creator' ? majorController.text.trim() : null,

        year: accountType == 'creator' ? yearController.text.trim() : null,

        industry: accountType == 'organization'
            ? industryController.text.trim()
            : null,

        tagline: accountType == 'organization'
            ? taglineController.text.trim()
            : null,

        skills: skills,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      showMessage(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                'JOIN SPOTLIGHT',

                style: TextStyle(
                  fontSize: 36,

                  fontWeight: FontWeight.bold,

                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 30),

              GlassCard(
                child: Column(
                  children: [
                    AccountTypeCard(
                      title: 'Creator',

                      subtitle: 'Show your talent',

                      icon: Icons.person,

                      selected: accountType == 'creator',

                      onTap: () {
                        setState(() {
                          accountType = 'creator';
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    AccountTypeCard(
                      title: 'Organization',

                      subtitle: 'Find talented people',

                      icon: Icons.business,

                      selected: accountType == 'organization',

                      onTap: () {
                        setState(() {
                          accountType = 'organization';
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    input(nameController, 'Name'),

                    input(emailController, 'Email'),

                    input(passwordController, 'Password', true),

                    if (accountType == 'creator') ...[
                      input(schoolController, 'University'),

                      input(majorController, 'Major'),

                      input(yearController, 'Year'),
                    ] else ...[
                      input(industryController, 'Industry'),

                      input(taglineController, 'Tagline'),
                    ],

                    input(skillsController, 'Skills (Flutter, UI, Music...)'),

                    const SizedBox(height: 20),

                    SpotlightButton(
                      text: loading ? 'CREATING...' : 'CREATE ACCOUNT',

                      onPressed: loading ? null : register,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget input(
    TextEditingController controller,

    String label, [

    bool password = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,

        obscureText: password,

        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
