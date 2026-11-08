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

  /// Реєстрація виходу з облікового запису (ручна дія)
  Future<void> logLogout() async {
    await logEvent(
      name: 'logout',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Реєстрація оновлення даних профілю (ручна дія: ім'я, фото)
  Future<void> logProfileUpdate({required String field, String? value}) async {
    final params = <String, Object>{'field': field};
    if (value != null) params['value'] = value;
    await logEvent(
      name: 'profile_update',
      parameters: params,
    );
  }

  /// Реєстрація успішної зміни пароля користувачем (ручна дія)
  Future<void> logPasswordChange() async {
    await logEvent(
      name: 'password_change',
      parameters: {'method': 'in_app_profile'},
    );
  }

  /// Реєстрація запиту на відновлення пароля (ручна дія)
  Future<void> logPasswordResetRequested({required String email}) async {
    await logEvent(
      name: 'password_reset_request',
      parameters: {
        'email_domain': email.contains('@') ? email.split('@').last : 'unknown',
      },
    );
  }

  /// Реєстрація ручних дій користувача з автомобілем (натискання кнопок ТО/пробігу)
  Future<void> logVehicleAction({required String action, String? detail}) async {
    final params = <String, Object>{'action': action};
    if (detail != null) params['detail'] = detail;
    await logEvent(
      name: 'vehicle_action',
      parameters: params,
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
