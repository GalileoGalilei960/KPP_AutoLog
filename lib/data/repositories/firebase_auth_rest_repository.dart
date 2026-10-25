import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/firebase_config.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

/// Реалізація AuthRepository через Firebase Authentication REST API.
/// 
/// Оптимальне рішення для платформи Linux (згідно з методичкою, стор. 6),
/// оскільки офіційний FlutterFire SDK наразі не має нативної C++ реалізації для Linux Desktop.
class FirebaseAuthRestRepository implements AuthRepository {
  static const String _authEndpoint = 'https://identitytoolkit.googleapis.com/v1';
  static const String _storageKey = 'autolog_current_user';

  final http.Client _client;
  final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _currentUser;

  FirebaseAuthRestRepository({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString(_storageKey);
      if (userDataStr != null && userDataStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(userDataStr);
        final user = AuthUser.fromJson(data);

        // Якщо є збережений токен і налаштовано API-ключ, перевіряємо актуальність
        if (user.idToken != null && FirebaseConfig.isConfigured) {
          try {
            await _lookupUser(user.idToken!);
            return;
          } catch (_) {
            // Якщо токен застарів, сеанс очищається
            await signOut();
            return;
          }
        } else {
          _updateUser(user);
        }
      }
    } catch (_) {
      // Ігноруємо помилки зчитування кешу
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (!FirebaseConfig.isConfigured) {
      // Демонстраційний локальний режим, якщо ключ Firebase ще не вказано
      await Future.delayed(const Duration(milliseconds: 600));
      final user = AuthUser(
        uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        displayName: displayName?.trim() ?? 'Остап Галадій',
        photoUrl: null,
      );
      await _saveUser(user);
      return;
    }

    final url = Uri.parse('$_authEndpoint/accounts:signUp?key=${FirebaseConfig.apiKey}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final data = _handleResponse(response);

    var user = AuthUser(
      uid: data['localId'] as String,
      email: data['email'] as String,
      idToken: data['idToken'] as String?,
      refreshToken: data['refreshToken'] as String?,
      tokenExpiresAt: DateTime.now().add(
        Duration(seconds: int.tryParse(data['expiresIn'] ?? '3600') ?? 3600),
      ),
    );

    // Якщо користувач вказав ім'я при реєстрації, оновлюємо профіль у Firebase
    if (displayName != null && displayName.trim().isNotEmpty && user.idToken != null) {
      try {
        final updateUrl = Uri.parse('$_authEndpoint/accounts:update?key=${FirebaseConfig.apiKey}');
        final updateResponse = await _client.post(
          updateUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'idToken': user.idToken,
            'displayName': displayName.trim(),
            'returnSecureToken': true,
          }),
        );
        if (updateResponse.statusCode == 200) {
          final updateData = jsonDecode(updateResponse.body);
          user = user.copyWith(
            displayName: updateData['displayName'] as String? ?? displayName.trim(),
            idToken: updateData['idToken'] as String? ?? user.idToken,
          );
        }
      } catch (_) {
        user = user.copyWith(displayName: displayName.trim());
      }
    }

    await _saveUser(user);
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (!FirebaseConfig.isConfigured) {
      await Future.delayed(const Duration(milliseconds: 600));
      final user = AuthUser(
        uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        displayName: 'Галадій Остап',
      );
      await _saveUser(user);
      return;
    }

    final url = Uri.parse('$_authEndpoint/accounts:signInWithPassword?key=${FirebaseConfig.apiKey}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final data = _handleResponse(response);

    final user = AuthUser(
      uid: data['localId'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoUrl: data['profilePicture'] as String?,
      idToken: data['idToken'] as String?,
      refreshToken: data['refreshToken'] as String?,
      tokenExpiresAt: DateTime.now().add(
        Duration(seconds: int.tryParse(data['expiresIn'] ?? '3600') ?? 3600),
      ),
    );

    await _saveUser(user);
  }

  @override
  Future<void> signInWithGoogle({
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final resolvedEmail = email ?? 'ostaphaladii@gmail.com';
    final resolvedName = displayName ?? 'Остап Галадій';
    final resolvedPhoto = photoUrl ??
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';

    final user = AuthUser(
      uid: 'google_${resolvedEmail.hashCode.abs()}',
      email: resolvedEmail,
      displayName: resolvedName,
      photoUrl: resolvedPhoto,
    );
    await _saveUser(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (!FirebaseConfig.isConfigured) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final url = Uri.parse('$_authEndpoint/accounts:sendOobCode?key=${FirebaseConfig.apiKey}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestType': 'PASSWORD_RESET',
        'email': email.trim(),
      }),
    );

    _handleResponse(response);
  }

  @override
  Future<void> updateDisplayName(String name) async {
    if (_currentUser == null) {
      throw const AuthException('Користувач не авторизований');
    }

    if (!FirebaseConfig.isConfigured || _currentUser!.idToken == null) {
      final updated = _currentUser!.copyWith(displayName: name.trim());
      await _saveUser(updated);
      return;
    }

    final url = Uri.parse('$_authEndpoint/accounts:update?key=${FirebaseConfig.apiKey}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': _currentUser!.idToken,
        'displayName': name.trim(),
        'returnSecureToken': true,
      }),
    );

    final data = _handleResponse(response);
    final updated = _currentUser!.copyWith(
      displayName: data['displayName'] as String? ?? name.trim(),
      idToken: data['idToken'] as String? ?? _currentUser!.idToken,
    );
    await _saveUser(updated);
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    if (_currentUser == null) {
      throw const AuthException('Користувач не авторизований');
    }

    if (!FirebaseConfig.isConfigured || _currentUser!.idToken == null) {
      final updated = _currentUser!.copyWith(photoUrl: photoUrl.trim());
      await _saveUser(updated);
      return;
    }

    final url = Uri.parse('$_authEndpoint/accounts:update?key=${FirebaseConfig.apiKey}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': _currentUser!.idToken,
        'photoUrl': photoUrl.trim(),
        'returnSecureToken': true,
      }),
    );

    final data = _handleResponse(response);
    final updated = _currentUser!.copyWith(
      photoUrl: data['photoUrl'] as String? ?? photoUrl.trim(),
      idToken: data['idToken'] as String? ?? _currentUser!.idToken,
    );
    await _saveUser(updated);
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    String? currentPassword,
  }) async {
    if (_currentUser == null) {
      throw const AuthException('Користувач не авторизований');
    }

    if (!FirebaseConfig.isConfigured || _currentUser!.idToken == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    // Якщо передано поточний пароль, виконуємо повторну автентифікацію (re-authenticate)
    // для запобігання помилки CREDENTIAL_TOO_OLD_LOGIN_AGAIN (стор. 12 методички)
    String activeToken = _currentUser!.idToken!;
    if (currentPassword != null && currentPassword.isNotEmpty) {
      try {
        final reauthUrl = Uri.parse(
          '$_authEndpoint/accounts:signInWithPassword?key=${FirebaseConfig.apiKey}',
        );
        final reauthRes = await _client.post(
          reauthUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _currentUser!.email,
            'password': currentPassword,
            'returnSecureToken': true,
          }),
        );
        if (reauthRes.statusCode == 200) {
          final reauthData = jsonDecode(reauthRes.body);
          activeToken = reauthData['idToken'] as String? ?? activeToken;
        } else {
          throw const AuthException('Поточний пароль введено невірно');
        }
      } catch (e) {
        if (e is AuthException) rethrow;
        throw const AuthException('Не вдалося перевірити поточний пароль');
      }
    }

    final url = Uri.parse('$_authEndpoint/accounts:update?key=${FirebaseConfig.apiKey}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': activeToken,
        'password': newPassword,
        'returnSecureToken': true,
      }),
    );

    final data = _handleResponse(response);
    final updated = _currentUser!.copyWith(
      idToken: data['idToken'] as String? ?? activeToken,
      refreshToken: data['refreshToken'] as String? ?? _currentUser!.refreshToken,
    );
    await _saveUser(updated);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }

  Future<void> _lookupUser(String idToken) async {
    final url = Uri.parse('$_authEndpoint/accounts:lookup?key=${FirebaseConfig.apiKey}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final users = data['users'] as List?;
      if (users != null && users.isNotEmpty) {
        final u = users.first as Map<String, dynamic>;
        final user = AuthUser(
          uid: u['localId'] as String,
          email: u['email'] as String? ?? _currentUser?.email ?? '',
          displayName: u['displayName'] as String? ?? _currentUser?.displayName,
          photoUrl: u['photoUrl'] as String? ?? _currentUser?.photoUrl,
          idToken: idToken,
        );
        _updateUser(user);
        return;
      }
    }
    throw const AuthException('Сеанс завершено');
  }

  void _updateUser(AuthUser user) {
    _currentUser = user;
    _authStateController.add(_currentUser);
  }

  Future<void> _saveUser(AuthUser user) async {
    _updateUser(user);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>?;
      final errorMessage = error?['message'] as String? ?? '';

      throw _mapFirebaseErrorToUkrainian(errorMessage);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Помилка запиту: ${response.statusCode}. Перевірте підключення до мережі.',
      );
    }
  }

  AuthException _mapFirebaseErrorToUkrainian(String code) {
    if (code.contains('EMAIL_EXISTS')) {
      return const AuthException(
        'Користувач із цією електронною адресою вже зареєстрований.',
        code: 'EMAIL_EXISTS',
      );
    }
    if (code.contains('EMAIL_NOT_FOUND') ||
        code.contains('INVALID_PASSWORD') ||
        code.contains('INVALID_LOGIN_CREDENTIALS')) {
      return const AuthException(
        'Невірна електронна пошта або пароль. Перевірте введені дані.',
        code: 'INVALID_CREDENTIALS',
      );
    }
    if (code.contains('USER_DISABLED')) {
      return const AuthException(
        'Цей обліковий запис було заблоковано адміністратором.',
        code: 'USER_DISABLED',
      );
    }
    if (code.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
      return const AuthException(
        'Забагато невдалих спроб входу. Спробуйте пізніше або відновіть пароль.',
        code: 'TOO_MANY_ATTEMPTS',
      );
    }
    if (code.contains('WEAK_PASSWORD')) {
      return const AuthException(
        'Пароль занадто простий. Він має містити щонайменше 6 символів.',
        code: 'WEAK_PASSWORD',
      );
    }
    if (code.contains('CREDENTIAL_TOO_OLD_LOGIN_AGAIN') ||
        code.contains('TOKEN_EXPIRED')) {
      return const AuthException(
        'Термін сеансу вичерпано. Будь ласка, виконайте вхід знову.',
        code: 'requires-recent-login',
      );
    }
    return AuthException('Помилка авторизації: $code', code: code);
  }
}
