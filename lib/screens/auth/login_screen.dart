import 'package:flutter/material.dart';

import '../../core/auth/auth_scope.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/crashlytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/google_button.dart';
import '../../core/widgets/info_banner.dart';
import '../../data/repositories/auth_repository.dart';
import 'forgot_password_dialog.dart';
import 'widgets/google_account_picker_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showHelpBanner = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'LoginScreen');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = AuthScope.repositoryOf(context);
      await repository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await AnalyticsService.instance.logLogin(loginMethod: 'email_password');

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e, stack) {
      CrashlyticsService.instance.recordError(
        e,
        stack,
        reason: 'Login failed unexpectedly',
        fatal: false,
      );
      if (mounted) {
        setState(() => _errorMessage = 'Сталася неочікувана помилка при вході');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onGoogleLogin() async {
    final account = await GoogleAccountPickerDialog.show(context);
    if (account == null || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = AuthScope.repositoryOf(context);
      await repository.signInWithGoogle(
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );

      await AnalyticsService.instance.logLogin(loginMethod: 'google');

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e, stack) {
      CrashlyticsService.instance.recordError(
        e,
        stack,
        reason: 'Google sign in error',
        fatal: false,
      );
      if (mounted) {
        setState(() => _errorMessage = 'Не вдалося виконати вхід через Google');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                child: Form(
                  key: _formKey,
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
                      const SizedBox(height: 20),

                      // Error message container if present
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, size: 18, color: Color(0xFFB91C1C)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field with validation
                      AppTextField(
                        label: 'Email',
                        hint: 'name@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 16),

                      // Password Field with validation
                      AppTextField(
                        label: 'Пароль',
                        controller: _passwordController,
                        isPassword: true,
                        enabled: !_isLoading,
                        validator: AppValidators.password,
                      ),
                      const SizedBox(height: 20),

                      // Google login button
                      GoogleButton(
                        text: 'Увійти через Google',
                        isLoading: _isLoading,
                        onPressed: _onGoogleLogin,
                      ),
                      const SizedBox(height: 12),

                      // Submit button
                      AppButton.primary(
                        text: 'Увійти',
                        isLoading: _isLoading,
                        onPressed: _onLogin,
                      ),
                      const SizedBox(height: 16),

                      // Forgot Password link
                      InkWell(
                        onTap: _isLoading ? null : _onForgotPassword,
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
                        onTap: _isLoading ? null : _onNavigateToRegister,
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
      ),
    );
  }
}
