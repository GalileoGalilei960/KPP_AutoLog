import 'package:flutter_test/flutter_test.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/core/utils/validators.dart';

void main() {
  group('AppValidators tests (Лабораторна робота №4 - Завдання 5)', () {
    test('Email validator correctly validates addresses', () {
      expect(AppValidators.email(null), contains('Введіть адресу'));
      expect(AppValidators.email(''), contains('Введіть адресу'));
      expect(AppValidators.email('invalid-email'), contains('коректний email'));
      expect(AppValidators.email('user@'), contains('коректний email'));
      expect(AppValidators.email('user@domain'), contains('коректний email'));
      expect(AppValidators.email('ostaphaladii@gmail.com'), isNull);
      expect(AppValidators.email('test.user+tag@domain.co.ua'), isNull);
    });

    test('Password validator checks minimum length of 6 characters', () {
      expect(AppValidators.password(null), contains('Введіть пароль'));
      expect(AppValidators.password(''), contains('Введіть пароль'));
      expect(AppValidators.password('12345'), contains('щонайменше 6 символів'));
      expect(AppValidators.password('123456'), isNull);
      expect(AppValidators.password('superStrongPassword!'), isNull);
    });

    test('Confirm password validator verifies match', () {
      expect(
        AppValidators.confirmPassword(null, 'password123'),
        contains('Повторіть пароль'),
      );
      expect(
        AppValidators.confirmPassword('wrongPassword', 'password123'),
        contains('не збігаються'),
      );
      expect(
        AppValidators.confirmPassword('password123', 'password123'),
        isNull,
      );
    });

    test('Required name validator checks minimum 2 characters', () {
      expect(AppValidators.requiredName(null), contains("Введіть ваше ім'я"));
      expect(AppValidators.requiredName(''), contains("Введіть ваше ім'я"));
      expect(AppValidators.requiredName('A'), contains('щонайменше 2 символи'));
      expect(AppValidators.requiredName('Остап Галадій'), isNull);
    });

    test('HTTPS URL validator validates image URLs', () {
      expect(AppValidators.httpsUrl(null), contains('Введіть посилання'));
      expect(AppValidators.httpsUrl(''), contains('Введіть посилання'));
      expect(AppValidators.httpsUrl('ftp://example.com/image.png'), contains('https://'));
      expect(AppValidators.httpsUrl('not_a_url'), contains('https://'));
      expect(AppValidators.httpsUrl('https://images.unsplash.com/photo-1'), isNull);
    });
  });
}
