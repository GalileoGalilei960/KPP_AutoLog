/// Утиліти валідації форм відповідно до вимог Завдання 5 (стор. 13-14, 16 методички)
class AppValidators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Валідація електронної пошти
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть адресу електронної пошти';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Введіть коректний email (наприклад, user@example.com)';
    }
    return null;
  }

  /// Валідація пароля (вимога Firebase: мінімум 6 символів)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль';
    }
    if (value.length < 6) {
      return 'Пароль повинен містити щонайменше 6 символів';
    }
    return null;
  }

  /// Валідація повторення пароля
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Повторіть пароль для підтвердження';
    }
    if (value != originalPassword) {
      return 'Паролі не збігаються';
    }
    return null;
  }

  /// Валідація обов'язкового імені користувача
  static String? requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Введіть ваше ім'я та прізвище";
    }
    if (value.trim().length < 2) {
      return "Ім'я має містити щонайменше 2 символи";
    }
    return null;
  }

  /// Валідація HTTPS-посилання (для фото профілю)
  static String? httpsUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть посилання на зображення';
    }
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.isAbsolute ||
        !['http', 'https'].contains(uri.scheme)) {
      return 'Введіть дійсне посилання (починається з https://)';
    }
    return null;
  }
}
