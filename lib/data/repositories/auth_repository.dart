import '../models/auth_user.dart';

/// Виняток автентифікації зі зрозумілим повідомленням користувачеві
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Абстрактний інтерфейс репозиторію автентифікації.
/// Згідно з вимогами лабораторної роботи №4 (пункт 4), відокремлює бізнес-логіку
/// від користувацького інтерфейсу.
abstract class AuthRepository {
  /// Потік змін стану автентифікації користувача (сеансу)
  Stream<AuthUser?> get authStateChanges;

  /// Поточний залогінений користувач (або null, якщо гість)
  AuthUser? get currentUser;

  /// Чи авторизований користувач на даний момент
  bool get isAuthenticated => currentUser != null;

  /// Ініціалізація стану (відновлення збереженого сеансу)
  Future<void> initialize();

  /// Реєстрація нового користувача за email та паролем
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Вхід за email та паролем
  Future<void> signIn({required String email, required String password});

  /// Вхід через Google
  Future<void> signInWithGoogle({
    String? email,
    String? displayName,
    String? photoUrl,
  });

  /// Запит на відновлення пароля (надсилання листа на email)
  Future<void> sendPasswordResetEmail(String email);

  /// Оновлення відображуваного імені користувача
  Future<void> updateDisplayName(String name);

  /// Оновлення посилання на аватарку користувача
  Future<void> updatePhotoUrl(String photoUrl);

  /// Зміна пароля з можливістю повторної автентифікації поточним паролем
  Future<void> updatePassword({
    required String newPassword,
    String? currentPassword,
  });

  /// Вихід з облікового запису та очищення сеансу
  Future<void> signOut();
}
