/// Конфігурація для підключення до Google Firebase.
///
/// Значення можна отримати у Firebase Console:
/// Project Settings (Налаштування проєкту) -> General (Загальні) -> Web API Key (Ключ веб-API)
class FirebaseConfig {
  /// Ключ веб-API Firebase. Можна передати через --dart-define=FIREBASE_API_KEY=...
  /// або вказати тут безпосередньо.
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBNs9mGFc2Lixao7rQrRTd5yaV4G9m3vSM',
  );

  /// Ідентифікатор проєкту Firebase (Project ID).
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'kpp-lab-autoservice',
  );

  /// Google OAuth 2.0 Client ID (тип «Web application»).
  ///
  /// Отримати можна в Google Cloud Console:
  /// APIs & Services -> Credentials -> OAuth 2.0 Client IDs
  ///
  /// Передається через --dart-define=GOOGLE_CLIENT_ID=...
  /// або через --dart-define-from-file=secrets.json
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  /// Google OAuth 2.0 Client Secret.
  ///
  /// Передається через --dart-define=GOOGLE_CLIENT_SECRET=...
  /// або через --dart-define-from-file=secrets.json
  static const String googleClientSecret = String.fromEnvironment(
    'GOOGLE_CLIENT_SECRET',
    defaultValue: '',
  );

  /// Перевірка чи налаштовано ключ API
  static bool get isConfigured => apiKey.isNotEmpty;

  /// Перевірка чи налаштовано Google OAuth
  static bool get isOAuthConfigured =>
      googleClientId.isNotEmpty && googleClientSecret.isNotEmpty;
}
