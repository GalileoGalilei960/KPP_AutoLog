import 'package:flutter/material.dart';
import '../../core/auth/auth_scope.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/crashlytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/repositories/auth_repository.dart';
import 'widgets/avatar_selection_dialog.dart';
import 'widgets/diagnostic_logs_dialog.dart';
import 'widgets/edit_name_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedCurrency = 'UAH';
  String _selectedUnit = 'km'; // 'km' or 'miles'

  final _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'ProfileScreen');
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Вихід із системи'),
        content: const Text('Ви дійсно бажаєте вийти зі свого облікового запису?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerText,
              foregroundColor: Colors.white,
            ),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthScope.repositoryOf(context).signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  Future<void> _onChangePhoto() async {
    final currentUser = AuthScope.of(context).currentUser;
    final newPhotoUrl = await AvatarSelectionDialog.show(
      context,
      currentPhotoUrl: currentUser?.photoUrl,
    );

    if (newPhotoUrl != null && mounted) {
      try {
        final repository = AuthScope.repositoryOf(context);
        await repository.updatePhotoUrl(newPhotoUrl);
        _showNotice('Фото профілю успішно оновлено');
      } on AuthException catch (e) {
        _showNotice(e.message, isError: true);
      } catch (_) {
        _showNotice('Помилка при оновленні фото', isError: true);
      }
    }
  }

  Future<void> _onEditName() async {
    final currentUser = AuthScope.of(context).currentUser;
    final newName = await EditNameDialog.show(
      context,
      currentName: currentUser?.effectiveDisplayName ?? '',
    );

    if (newName != null && mounted) {
      try {
        final repository = AuthScope.repositoryOf(context);
        await repository.updateDisplayName(newName);
        _showNotice("Ім'я успішно оновлено");
      } on AuthException catch (e) {
        _showNotice(e.message, isError: true);
      } catch (_) {
        _showNotice("Помилка при оновленні імені", isError: true);
      }
    }
  }

  Future<void> _onUpdatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final repository = AuthScope.repositoryOf(context);
      await repository.updatePassword(
        newPassword: _newPasswordController.text,
        currentPassword: _currentPasswordController.text.trim().isNotEmpty
            ? _currentPasswordController.text
            : null,
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();

      _showNotice('Пароль успішно змінено!');
    } on AuthException catch (e) {
      _showNotice(e.message, isError: true);
    } catch (e, stack) {
      CrashlyticsService.instance.recordError(
        e,
        stack,
        reason: 'Password change failed',
        fatal: false,
      );
      _showNotice('Не вдалося змінити пароль. Спробуйте пізніше.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
    }
  }

  void _onTestCrashlytics() {
    CrashlyticsService.instance.simulateTestCrash(fatal: false);
    _showNotice('⚠️ Тестову нефатальну помилку зареєстровано у Crashlytics!');
  }

  void _showNotice(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? AppColors.dangerText : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).currentUser;
    final displayName = user?.effectiveDisplayName ?? 'Галадій Остап';
    final email = user?.email ?? 'ostaphaladii@gmail.com';
    final photoUrl = user?.photoUrl;
    final initials = user?.initials ?? 'ГО';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: AppCard(
            padding: const EdgeInsets.all(32),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with photo or initials
                    InkWell(
                      onTap: _onChangePhoto,
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.avatarBg,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: (photoUrl != null && photoUrl.isNotEmpty)
                                ? ClipOval(
                                    child: Image.network(
                                      photoUrl,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Text(
                                        initials,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.avatarText,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.avatarText,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // User name & email & edit actions
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                color: AppColors.textSecondary,
                                tooltip: "Редагувати ім'я",
                                onPressed: _onEditName,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: _onChangePhoto,
                            borderRadius: BorderRadius.circular(4),
                            child: const Text(
                              'Змінити фото профілю',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Account Type Badge
                    const AppBadge.neutral(text: 'Особистий акаунт'),
                  ],
                ),
                const SizedBox(height: 32),

                // Section: Налаштування
                const Text(
                  'Налаштування',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Currency and Units controls row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;

                    final currencyField = DropdownButtonFormField<String>(
                      initialValue: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Валюта (UAH/USD)',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'UAH', child: Text('UAH')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCurrency = val);
                      },
                    );

                    final unitsField = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Одиниці',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.inputBorder),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              // Km option
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _selectedUnit = 'km'),
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(22),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _selectedUnit == 'km'
                                          ? AppColors.primaryLight
                                          : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(22),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_selectedUnit == 'km') ...[
                                          const Icon(Icons.check,
                                              size: 15, color: AppColors.primary),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(
                                          'Км',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedUnit == 'km'
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(width: 1, color: AppColors.inputBorder),
                              // Miles option
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _selectedUnit = 'miles'),
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(22),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _selectedUnit == 'miles'
                                          ? AppColors.primaryLight
                                          : Colors.transparent,
                                      borderRadius: const BorderRadius.horizontal(
                                        right: Radius.circular(22),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_selectedUnit == 'miles') ...[
                                          const Icon(Icons.check,
                                              size: 15, color: AppColors.primary),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(
                                          'Милі',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedUnit == 'miles'
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: currencyField),
                          const SizedBox(width: 20),
                          Expanded(child: unitsField),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        currencyField,
                        const SizedBox(height: 16),
                        unitsField,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Section: Безпека (Валідація форми зміни пароля, Завдання 4.b, 5)
                Row(
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Безпека',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Змініть пароль, щоб захистити свій акаунт.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),

                // Password fields form with validation
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 500;

                          final currentPassField = AppTextField(
                            label: 'Поточний пароль',
                            hint: 'Введіть старий пароль',
                            controller: _currentPasswordController,
                            isPassword: true,
                            enabled: !_isChangingPassword,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Введіть поточний пароль';
                              }
                              return null;
                            },
                          );

                          final newPassField = AppTextField(
                            label: 'Новий пароль',
                            hint: 'Мінімум 6 символів',
                            controller: _newPasswordController,
                            isPassword: true,
                            enabled: !_isChangingPassword,
                            validator: AppValidators.password,
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: currentPassField),
                                const SizedBox(width: 20),
                                Expanded(child: newPassField),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              currentPassField,
                              const SizedBox(height: 16),
                              newPassField,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Підтвердження нового пароля',
                        hint: 'Повторіть новий пароль',
                        controller: _confirmNewPasswordController,
                        isPassword: true,
                        enabled: !_isChangingPassword,
                        validator: (v) => AppValidators.confirmPassword(
                          v,
                          _newPasswordController.text,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Hint and Update button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Пароль має містити щонайменше 6 символів (вимога Firebase).',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          AppButton.primary(
                            text: 'Оновити',
                            fullWidth: false,
                            height: 42,
                            isLoading: _isChangingPassword,
                            onPressed: _onUpdatePassword,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Інструменти діагностики (Crashlytics, Завдання 2)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bug_report_outlined,
                          size: 20,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Моніторинг збоїв (Firebase Crashlytics)',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Згенерувати тестову помилку для звіту Лабораторної №4',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.flash_on, size: 16),
                        label: const Text('Тест збою'),
                        onPressed: _onTestCrashlytics,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(color: Color(0xFFFCD34D)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.list_alt, size: 16),
                        label: const Text('Журнал подій'),
                        onPressed: () => DiagnosticLogsDialog.show(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Session Status Card
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      // Cloud icon circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.infoBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Session text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Сесію синхронізовано',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Linux Desktop · ${email.isNotEmpty ? email : "Локальний сеанс"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Logout button
                      AppButton.dangerOutlined(
                        text: 'Вийти з акаунта',
                        icon: const Icon(Icons.logout,
                            size: 16, color: AppColors.dangerText),
                        onPressed: _onLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
