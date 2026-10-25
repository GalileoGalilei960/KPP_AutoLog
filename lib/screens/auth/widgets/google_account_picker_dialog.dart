import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

/// Дані вибраного облікового запису Google
class GoogleAccountInfo {
  final String email;
  final String displayName;
  final String? photoUrl;

  const GoogleAccountInfo({
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

/// Діалог вибору облікового запису Google (Google Account Chooser)
/// Відтворює стандартну поведінку вибору акаунта для Linux Desktop
class GoogleAccountPickerDialog extends StatefulWidget {
  const GoogleAccountPickerDialog({super.key});

  static Future<GoogleAccountInfo?> show(BuildContext context) {
    return showDialog<GoogleAccountInfo>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const GoogleAccountPickerDialog(),
    );
  }

  @override
  State<GoogleAccountPickerDialog> createState() =>
      _GoogleAccountPickerDialogState();
}

class _GoogleAccountPickerDialogState extends State<GoogleAccountPickerDialog> {
  bool _isEnteringCustomAccount = false;
  final _customFormKey = GlobalKey<FormState>();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customEmailController = TextEditingController();

  // Доступні збережені облікові записи для швидкого вибору
  final List<GoogleAccountInfo> _savedAccounts = const [
    GoogleAccountInfo(
      displayName: 'Остап Галадій',
      email: 'ostaphaladii@gmail.com',
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=160',
    ),
    GoogleAccountInfo(
      displayName: 'Остап Галадій (НУ «Львівська Політехніка»)',
      email: 'ostap.haladii.pz@lpnu.ua',
      photoUrl: null,
    ),
  ];

  @override
  void dispose() {
    _customNameController.dispose();
    _customEmailController.dispose();
    super.dispose();
  }

  void _onSelect(GoogleAccountInfo account) {
    Navigator.of(context).pop(account);
  }

  void _onSubmitCustom() {
    if (!_customFormKey.currentState!.validate()) {
      return;
    }
    final account = GoogleAccountInfo(
      displayName: _customNameController.text.trim(),
      email: _customEmailController.text.trim(),
    );
    Navigator.of(context).pop(account);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Google Branding Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_logo.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Вхід через Google',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Оберіть обліковий запис для переходу до AutoLog',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              if (!_isEnteringCustomAccount) ...[
                // Список готових акаунтів
                ...List.generate(_savedAccounts.length, (index) {
                  final acc = _savedAccounts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _onSelect(acc),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 19,
                              backgroundColor: AppColors.avatarBg,
                              backgroundImage: acc.photoUrl != null
                                  ? NetworkImage(acc.photoUrl!)
                                  : null,
                              child: acc.photoUrl == null
                                  ? Text(
                                      acc.displayName.isNotEmpty
                                          ? acc.displayName[0].toUpperCase()
                                          : 'G',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.avatarText,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.displayName,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    acc.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Кнопка використання іншого акаунта
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _isEnteringCustomAccount = true),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            radius: 19,
                            backgroundColor: Color(0xFFF1F5F9),
                            child: Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Увійти з іншим акаунтом...',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Форма введення іншого Google акаунта
                Form(
                  key: _customFormKey,
                  child: Column(
                    children: [
                      AppTextField(
                        label: "Ім'я профілю Google",
                        hint: 'Остап Галадій',
                        controller: _customNameController,
                        validator: AppValidators.requiredName,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Google Email',
                        hint: 'name@gmail.com',
                        controller: _customEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(
                                () => _isEnteringCustomAccount = false,
                              ),
                              child: const Text('Назад'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton.primary(
                              text: 'Продовжити',
                              height: 42,
                              onPressed: _onSubmitCustom,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // Політика конфіденційності Google
              const Text(
                'Щоб продовжити, Google надасть сервісу AutoLog ваше ім’я, адресу електронної пошти та фотографію профілю.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Скасувати'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
