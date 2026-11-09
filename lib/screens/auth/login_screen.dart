import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/login_bloc.dart';
import '../../blocs/auth/login_event.dart';
import '../../blocs/auth/login_state.dart';
import '../../core/auth/auth_scope.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/google_button.dart';
import '../../core/widgets/info_banner.dart';
import 'forgot_password_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Відповідно до методичних вказівок (стор. 13), забезпечуємо наявність LoginBloc
    final authRepository = AuthScope.repositoryOf(context);
    return BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(authRepository),
      child: const _LoginFormView(),
    );
  }
}

class _LoginFormView extends StatefulWidget {
  const _LoginFormView();

  @override
  State<_LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<_LoginFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showHelpBanner = true;

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

  void _onLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.read<LoginBloc>().add(
          LoginSubmitted(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  void _onGoogleLogin(BuildContext context) {
    context.read<LoginBloc>().add(const GoogleLoginSubmitted());
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
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        final errorMessage = state is LoginError ? state.message : null;

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
                              message:
                                  'Допомога: перевірте правильність email і пароля. Якщо забули пароль — скористайтеся посиланням нижче.',
                              onClose: () =>
                                  setState(() => _showHelpBanner = false),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // App Logo
                          const Center(
                            child: AppLogo(iconSize: 34, fontSize: 22),
                          ),
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

                          // Error message container if present from BLoC state
                          if (errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 18,
                                    color: Color(0xFFB91C1C),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMessage,
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
                            enabled: !isLoading,
                            validator: AppValidators.email,
                          ),
                          const SizedBox(height: 16),

                          // Password Field with validation
                          AppTextField(
                            label: 'Пароль',
                            controller: _passwordController,
                            isPassword: true,
                            enabled: !isLoading,
                            validator: AppValidators.password,
                          ),
                          const SizedBox(height: 20),

                          // Google login button
                          GoogleButton(
                            text: 'Увійти через Google',
                            isLoading: isLoading,
                            onPressed:
                                isLoading ? null : () => _onGoogleLogin(context),
                          ),
                          const SizedBox(height: 12),

                          // Submit button
                          AppButton.primary(
                            text: 'Увійти',
                            isLoading: isLoading,
                            onPressed:
                                isLoading ? null : () => _onLogin(context),
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password link
                          InkWell(
                            onTap: isLoading ? null : _onForgotPassword,
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
                            onTap: isLoading ? null : _onNavigateToRegister,
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
      },
    );
  }
}
