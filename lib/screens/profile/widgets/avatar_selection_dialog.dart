import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

/// Діалог для вибору готового аватара або введення власного HTTPS-посилання з попереднім переглядом.
/// Відповідає вимогам Завдання 4.b (стор. 15 методички).
class AvatarSelectionDialog extends StatefulWidget {
  final String? currentPhotoUrl;

  const AvatarSelectionDialog({super.key, this.currentPhotoUrl});

  static Future<String?> show(BuildContext context, {String? currentPhotoUrl}) {
    return showDialog<String>(
      context: context,
      builder: (context) => AvatarSelectionDialog(currentPhotoUrl: currentPhotoUrl),
    );
  }

  @override
  State<AvatarSelectionDialog> createState() => _AvatarSelectionDialogState();
}

class _AvatarSelectionDialogState extends State<AvatarSelectionDialog> {
  static const List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=160',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=160',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=160',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=160',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=160',
  ];

  late final TextEditingController _customUrlController;
  final _formKey = GlobalKey<FormState>();
  String? _selectedUrl;

  @override
  void initState() {
    super.initState();
    _selectedUrl = widget.currentPhotoUrl;
    _customUrlController = TextEditingController(
      text: (_presetAvatars.contains(widget.currentPhotoUrl) || widget.currentPhotoUrl == null)
          ? ''
          : widget.currentPhotoUrl,
    );
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  void _onSelectPreset(String url) {
    setState(() {
      _selectedUrl = url;
      _customUrlController.clear();
    });
  }

  void _onCustomUrlChanged(String value) {
    setState(() {
      _selectedUrl = value.trim().isNotEmpty ? value.trim() : null;
    });
  }

  void _onSave() {
    if (_customUrlController.text.trim().isNotEmpty) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      Navigator.of(context).pop(_customUrlController.text.trim());
    } else {
      Navigator.of(context).pop(_selectedUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Зміна фото профілю',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Прев'ю вибраного фото
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 3),
                            color: AppColors.avatarBg,
                          ),
                          child: ClipOval(
                            child: _selectedUrl != null && _selectedUrl!.isNotEmpty
                                ? Image.network(
                                    _selectedUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      size: 32,
                                      color: AppColors.textSecondary,
                                    ),
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                  )
                                : const Icon(Icons.person, size: 40, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Оберіть із готових зображень:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Сітка готових зображень
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _presetAvatars.map((url) {
                      final isSelected = _selectedUrl == url;
                      return InkWell(
                        onTap: () => _onSelectPreset(url),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Або введіть власне HTTPS-посилання:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  AppTextField(
                    label: 'URL зображення (HTTPS)',
                    hint: 'https://example.com/avatar.jpg',
                    controller: _customUrlController,
                    onChanged: _onCustomUrlChanged,
                    validator: (v) {
                      if (v != null && v.trim().isNotEmpty) {
                        return AppValidators.httpsUrl(v);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Скасувати'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.primary(
                          text: 'Зберегти',
                          height: 44,
                          onPressed: _onSave,
                        ),
                      ),
                    ],
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
