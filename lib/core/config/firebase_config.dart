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

  /// Перевірка чи налаштовано ключ API
  static bool get isConfigured => apiKey.isNotEmpty;
}
