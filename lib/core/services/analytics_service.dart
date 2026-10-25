import 'dart:developer' as developer;

/// Сервіс аналітики для відстеження дій користувача та переходів між екранами.
/// Відповідає вимогам Завдання 1 (стор. 7, 14 методички).
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static AnalyticsService get instance => _instance;

  /// Журнал подій аналітики (для перевірки та звіту)
  final List<Map<String, dynamic>> _eventsLog = [];
  List<Map<String, dynamic>> get eventsLog => List.unmodifiable(_eventsLog);

  /// Реєстрація довільної події (метод logEvent)
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    final eventRecord = {
      'timestamp': DateTime.now().toIso8601String(),
      'name': name,
      'parameters': parameters ?? {},
    };
    _eventsLog.add(eventRecord);

    // ignore: avoid_print
    print('📊 [Firebase Analytics Event] $name : $parameters');

    developer.log(
      '📊 [Analytics Event] $name : $parameters',
      name: 'AnalyticsService',
    );
  }

  /// Реєстрація входу користувача
  Future<void> logLogin({String? loginMethod = 'email_password'}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': loginMethod ?? 'email_password'},
    );
  }

  /// Реєстрація створення нового облікового запису
  Future<void> logSignUp({String? signUpMethod = 'email_password'}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': signUpMethod ?? 'email_password'},
    );
  }

  /// Реєстрація перегляду екрана (logScreenView)
  Future<void> logScreenView({required String screenName}) async {
    await logEvent(
      name: 'screen_view',
      parameters: {'screen_name': screenName},
    );
  }

  /// Очищення журналу (за потреби)
  void clearLogs() {
    _eventsLog.clear();
  }
}
