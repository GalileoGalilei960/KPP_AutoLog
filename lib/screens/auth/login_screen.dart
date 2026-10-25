import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/google_button.dart';
import '../../core/widgets/info_banner.dart';
import 'forgot_password_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(
    text: '••••••••••••',
  );

  bool _showHelpBanner = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    // Laboratory requirement: no business logic, navigate directly to main screen
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _onForgotPassword() async {
    final result = await ForgotPasswordDialog.show(context);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Лист із посиланням для скидання пароля надіслано на $result',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onNavigateToRegister() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 32,
                ),
                borderRadius: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Help info banner
                    if (_showHelpBanner) ...[
                      InfoBanner(
                        message: 'Допомога: перевірте правильність email і пароля. Якщо забули пароль — скористайтеся посиланням нижче.',
                        onClose: () => setState(() => _showHelpBanner = false),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // App Logo
                    const Center(child: AppLogo(iconSize: 34, fontSize: 22)),
                    const SizedBox(height: 18),

                    // Title
                    const Text(
                      'Увійти',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email Field
                    AppTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    AppTextField(
                      label: 'Пароль',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),

                    // Google login button
                    GoogleButton(
                      text: 'Увійти через Google',
                      onPressed: _onLogin,
                    ),
                    const SizedBox(height: 12),

                    // Submit button
                    AppButton.primary(text: 'Увійти', onPressed: _onLogin),
                    const SizedBox(height: 16),

                    // Forgot Password link
                    InkWell(
                      onTap: _onForgotPassword,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Text(
                          'Забули пароль?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Register link
                    InkWell(
                      onTap: _onNavigateToRegister,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Text(
                          'Немає акаунта? Зареєструватися',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
