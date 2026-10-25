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
import 'widgets/google_account_picker_dialog.dart';

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late bool _showBanner;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _showBanner = widget.showInitialConfirmationBanner;
    AnalyticsService.instance.logScreenView(screenName: 'RegisterScreen');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = AuthScope.repositoryOf(context);
      await repository.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _fullNameController.text,
      );

      await AnalyticsService.instance.logSignUp(signUpMethod: 'email_password');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Акаунт успішно зареєстровано! Ласкаво просимо.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
        reason: 'Register failed unexpectedly',
        fatal: false,
      );
      if (mounted) {
        setState(() => _errorMessage = 'Сталася помилка при реєстрації. Спробуйте пізніше.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onGoogleRegister() async {
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

      await AnalyticsService.instance.logSignUp(signUpMethod: 'google');

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
        reason: 'Google registration failed',
        fatal: false,
      );
      if (mounted) {
        setState(() => _errorMessage = 'Не вдалося зареєструватися через Google');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNavigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
                    child: Form(
                      key: _formKey,
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
                          const SizedBox(height: 20),

                          // Error message if present
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

                          // Form Fields
                          AppTextField(
                            label: "Повне ім'я",
                            hint: 'Тарас Шевченко',
                            controller: _fullNameController,
                            enabled: !_isLoading,
                            validator: AppValidators.requiredName,
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            label: 'Email',
                            hint: 'name@example.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            validator: AppValidators.email,
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            label: 'Пароль',
                            hint: '••••••••',
                            controller: _passwordController,
                            isPassword: true,
                            enabled: !_isLoading,
                            validator: AppValidators.password,
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            label: 'Підтвердження пароля',
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            isPassword: true,
                            enabled: !_isLoading,
                            validator: (v) => AppValidators.confirmPassword(
                              v,
                              _passwordController.text,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Google button
                          GoogleButton(
                            text: 'Зареєструватися через Google',
                            isLoading: _isLoading,
                            onPressed: _onGoogleRegister,
                          ),
                          const SizedBox(height: 12),

                          // Main action button
                          AppButton.primary(
                            text: 'Зареєструватися',
                            isLoading: _isLoading,
                            onPressed: _onRegister,
                          ),
                          const SizedBox(height: 20),

                          // Link to Login
                          InkWell(
                            onTap: _isLoading ? null : _onNavigateToLogin,
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Text(
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
