import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/google_button.dart';
import '../../core/widgets/info_banner.dart';
import '../shell/main_layout.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool showInitialConfirmationBanner;

  const RegisterScreen({
    super.key,
    this.showInitialConfirmationBanner = true,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late bool _showBanner;

  @override
  void initState() {
    super.initState();
    _showBanner = widget.showInitialConfirmationBanner;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    // Laboratory requirement: no business logic, navigate to main screen directly
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  void _onNavigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Banner from design
                  if (_showBanner) ...[
                    InfoBanner(
                      message: 'Лист із підтвердженням надіслано',
                      onClose: () => setState(() => _showBanner = false),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Registration Card
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        const Center(
                          child: AppLogo(iconSize: 34, fontSize: 22),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          'Створення акаунту',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Fields
                        AppTextField(
                          label: "Повне ім'я",
                          controller: _fullNameController,
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Пароль',
                          controller: _passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          label: 'Підтвердження',
                          controller: _confirmPasswordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 22),

                        // Google button
                        GoogleButton(
                          text: 'Зареєструватися через Google',
                          onPressed: _onRegister,
                        ),
                        const SizedBox(height: 12),

                        // Main action button
                        AppButton.primary(
                          text: 'Зареєструватися',
                          onPressed: _onRegister,
                        ),
                        const SizedBox(height: 20),

                        // Link to Login
                        InkWell(
                          onTap: _onNavigateToLogin,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: const Text(
                              'Вже є акаунт? Увійти',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
