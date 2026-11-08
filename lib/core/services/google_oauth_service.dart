import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../config/firebase_config.dart';

/// Результат Google OAuth авторизації
class GoogleOAuthResult {
  final String idToken;
  final String accessToken;
  final String? refreshToken;

  const GoogleOAuthResult({
    required this.idToken,
    required this.accessToken,
    this.refreshToken,
  });
}

/// Сервіс Google OAuth 2.0 для Linux Desktop.
///
/// Оскільки офіційний плагін google_sign_in не підтримує Linux,
/// реалізуємо OAuth 2.0 Authorization Code Flow з PKCE вручну:
///
/// 1. Генеруємо code_verifier та code_challenge (PKCE)
/// 2. Запускаємо локальний HTTP-сервер на localhost для отримання callback
/// 3. Відкриваємо браузер з URL авторизації Google
/// 4. Отримуємо authorization code через redirect на localhost
/// 5. Обмінюємо code на access_token та id_token
class GoogleOAuthService {
  static const String _authEndpoint =
      'https://accounts.google.com/o/oauth2/v2/auth';
  static const String _tokenEndpoint =
      'https://oauth2.googleapis.com/token';

  /// Таймаут очікування відповіді від браузера (користувач має встигнути залогінитись)
  static const Duration _authTimeout = Duration(minutes: 3);

  final http.Client _client;

  GoogleOAuthService({http.Client? client})
      : _client = client ?? http.Client();

  /// Виконує повний цикл Google OAuth авторизації.
  ///
  /// Відкриває системний браузер для входу в Google, чекає на callback
  /// і повертає токени. Кидає виняток, якщо користувач скасував
  /// або сталася помилка.
  Future<GoogleOAuthResult> signIn() async {
    if (!FirebaseConfig.isOAuthConfigured) {
      throw const GoogleOAuthException(
        'Google OAuth не налаштовано. Вкажіть GOOGLE_CLIENT_ID та GOOGLE_CLIENT_SECRET.',
      );
    }

    // 1. Генеруємо PKCE параметри
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final state = _generateState();

    // 2. Запускаємо локальний сервер для прийому redirect
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    final redirectUri = 'http://localhost:$port';

    try {
      // 3. Формуємо URL авторизації
      final authUrl = Uri.parse(_authEndpoint).replace(
        queryParameters: {
          'client_id': FirebaseConfig.googleClientId,
          'redirect_uri': redirectUri,
          'response_type': 'code',
          'scope': 'openid email profile',
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'state': state,
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );

      // 4. Відкриваємо браузер
      final launched = await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const GoogleOAuthException(
          'Не вдалося відкрити браузер для авторизації Google.',
        );
      }

      // 5. Чекаємо на callback
      final code = await _waitForAuthCode(server, state);

      // 6. Обмінюємо code на токени
      final result = await _exchangeCodeForTokens(
        code: code,
        codeVerifier: codeVerifier,
        redirectUri: redirectUri,
      );

      return result;
    } finally {
      await server.close(force: true);
    }
  }

  /// Очікує authorization code від локального HTTP-сервера.
  Future<String> _waitForAuthCode(HttpServer server, String expectedState) async {
    final completer = Completer<String>();

    // Таймаут — якщо користувач не завершив вхід протягом 3 хвилин
    final timer = Timer(_authTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError(const GoogleOAuthException(
          'Час очікування авторизації вичерпано. Спробуйте ще раз.',
        ));
      }
    });

    server.listen((request) async {
      try {
        final uri = request.uri;
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];
        final returnedState = uri.queryParameters['state'];

        if (error != null) {
          // Користувач скасував або сталася помилка
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.html
            ..write(_buildHtmlPage(
              title: 'Авторизацію скасовано',
              message: 'Ви можете закрити цю вкладку та повернутися до програми.',
              isError: true,
            ));
          await request.response.close();

          if (!completer.isCompleted) {
            completer.completeError(const GoogleOAuthException(
              'Авторизацію Google було скасовано.',
            ));
          }
          return;
        }

        if (code == null || returnedState != expectedState) {
          request.response
            ..statusCode = 400
            ..headers.contentType = ContentType.html
            ..write(_buildHtmlPage(
              title: 'Помилка авторизації',
              message: 'Невірні параметри відповіді. Спробуйте ще раз.',
              isError: true,
            ));
          await request.response.close();
          return;
        }

        // Успіх — відображаємо сторінку підтвердження
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write(_buildHtmlPage(
            title: 'Авторизація успішна!',
            message: 'Ви успішно увійшли через Google. Можете закрити цю вкладку та повернутися до AutoLog.',
            isError: false,
          ));
        await request.response.close();

        if (!completer.isCompleted) {
          completer.complete(code);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(GoogleOAuthException(
            'Помилка обробки відповіді: $e',
          ));
        }
      }
    });

    try {
      return await completer.future;
    } finally {
      timer.cancel();
    }
  }

  /// Обмінює authorization code на access_token та id_token.
  Future<GoogleOAuthResult> _exchangeCodeForTokens({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    final response = await _client.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': FirebaseConfig.googleClientId,
        'client_secret': FirebaseConfig.googleClientSecret,
        'code': code,
        'code_verifier': codeVerifier,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final error = body['error_description'] ?? body['error'] ?? 'Unknown error';
      throw GoogleOAuthException(
        'Не вдалося отримати токени Google: $error',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final idToken = data['id_token'] as String?;
    final accessToken = data['access_token'] as String?;

    if (idToken == null || accessToken == null) {
      throw const GoogleOAuthException(
        'Google не повернув необхідні токени. Спробуйте ще раз.',
      );
    }

    return GoogleOAuthResult(
      idToken: idToken,
      accessToken: accessToken,
      refreshToken: data['refresh_token'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // PKCE helpers
  // ---------------------------------------------------------------------------

  /// Генерує випадковий code_verifier (43-128 символів, URL-safe base64).
  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// Генерує code_challenge = BASE64URL(SHA256(code_verifier)).
  String _generateCodeChallenge(String codeVerifier) {
    final digest = sha256.convert(utf8.encode(codeVerifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Генерує випадковий state параметр для захисту від CSRF.
  String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  // ---------------------------------------------------------------------------
  // HTML callback page
  // ---------------------------------------------------------------------------

  String _buildHtmlPage({
    required String title,
    required String message,
    required bool isError,
  }) {
    final color = isError ? '#dc2626' : '#16a34a';
    final icon = isError ? '✗' : '✓';
    return '''
<!DOCTYPE html>
<html lang="uk">
<head>
  <meta charset="utf-8">
  <title>AutoLog — $title</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex; align-items: center; justify-content: center;
      min-height: 100vh; margin: 0;
      background: #f8fafc; color: #1e293b;
    }
    .card {
      text-align: center; padding: 48px;
      background: white; border-radius: 16px;
      box-shadow: 0 4px 24px rgba(0,0,0,.08);
      max-width: 420px;
    }
    .icon { font-size: 48px; color: $color; margin-bottom: 16px; }
    h1 { font-size: 22px; margin: 0 0 12px; }
    p { font-size: 15px; color: #64748b; line-height: 1.5; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">$icon</div>
    <h1>$title</h1>
    <p>$message</p>
  </div>
</body>
</html>
''';
  }
}

/// Виняток Google OAuth
class GoogleOAuthException implements Exception {
  final String message;
  const GoogleOAuthException(this.message);

  @override
  String toString() => message;
}

