import 'dart:developer' as developer;

/// Модель запису користувача в аудієнції (хто і як залогінився).
/// Дозволяє сегментувати користувачів та відстежувати способи автентифікації.
class AudienceRecord {
  final String userId;
  final String email;
  final String? displayName;
  final String method; // 'google', 'email_password', 'saved_session' тощо
  final DateTime timestamp;
  final Map<String, String> userProperties;

  const AudienceRecord({
    required this.userId,
    required this.email,
    this.displayName,
    required this.method,
    required this.timestamp,
    this.userProperties = const {},
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'email': email,
    'displayName': displayName,
    'method': method,
    'timestamp': timestamp.toIso8601String(),
    'userProperties': userProperties,
  };
}

/// Сервіс аналітики для відстеження дій користувача, переходів між екранами
/// та збору даних аудієнції (хто і як авторизувався в системі).
/// Відповідає вимогам Завдання 1 (стор. 7, 14 методички).
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static AnalyticsService get instance => _instance;

  /// Журнал подій аналітики (для перевірки та звіту)
  final List<Map<String, dynamic>> _eventsLog = [];
  List<Map<String, dynamic>> get eventsLog => List.unmodifiable(_eventsLog);

  /// Поточний ідентифікатор користувача (setUserId)
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  /// Поточні властивості користувача (setUserProperty)
  final Map<String, String> _userProperties = {};
  Map<String, String> get userProperties => Map.unmodifiable(_userProperties);

  /// Журнал аудієнції: хто і як залогінився
  final List<AudienceRecord> _audienceLog = [];
  List<AudienceRecord> get audienceLog => List.unmodifiable(_audienceLog);

  /// Встановлення ID користувача для аналітики та аудиторії
  Future<void> setUserId(String? id) async {
    _currentUserId = id;
    if (id != null) {
      _userProperties['user_id'] = id;
    } else {
      _userProperties.remove('user_id');
    }

    // ignore: avoid_print
    print('👤 [Firebase Analytics Audience] setUserId: $id');
    developer.log('👤 [Analytics Audience] setUserId: $id', name: 'AnalyticsService');
  }

  /// Встановлення користувацьких властивостей (User Properties) для аудиторії
  Future<void> setUserProperty({required String name, required String? value}) async {
    if (value != null) {
      _userProperties[name] = value;
    } else {
      _userProperties.remove(name);
    }

    // ignore: avoid_print
    print('🏷️ [Firebase Analytics Property] $name = $value');
    developer.log('🏷️ [Analytics Property] $name = $value', name: 'AnalyticsService');
  }

  /// Фіксація інформації про користувача в аудієнції (хто і як залогінився)
  Future<void> recordAudienceLogin({
    required String userId,
    required String email,
    String? displayName,
    required String method,
    Map<String, String>? extraProperties,
  }) async {
    await setUserId(userId);
    final domain = email.contains('@') ? email.split('@').last : 'unknown';
    await setUserProperty(name: 'email', value: email);
    await setUserProperty(name: 'email_domain', value: domain);
    await setUserProperty(name: 'auth_method', value: method);
    await setUserProperty(name: 'platform', value: 'linux');
    if (displayName != null && displayName.isNotEmpty) {
      await setUserProperty(name: 'display_name', value: displayName);
    }
    await setUserProperty(name: 'last_login', value: DateTime.now().toIso8601String());

    if (extraProperties != null) {
      for (final entry in extraProperties.entries) {
        await setUserProperty(name: entry.key, value: entry.value);
      }
    }

    final record = AudienceRecord(
      userId: userId,
      email: email,
      displayName: displayName,
      method: method,
      timestamp: DateTime.now(),
      userProperties: Map<String, String>.from(_userProperties),
    );
    _audienceLog.add(record);

    // ignore: avoid_print
    print('👥 [Firebase Audience Captured] Користувач: $email ($userId) | Метод: $method');
    developer.log(
      '👥 [Audience Captured] User: $email ($userId) | Method: $method',
      name: 'AnalyticsService',
    );
  }

  /// Список унікальних користувачів в аудієнції
  List<AudienceRecord> get uniqueAudience {
    final Map<String, AudienceRecord> map = {};
    for (final rec in _audienceLog) {
      final key = rec.userId.isNotEmpty ? rec.userId : rec.email;
      if (key.isNotEmpty) {
        map[key] = rec;
      }
    }
    return map.values.toList();
  }

  /// Кількість авторизацій через Google
  int get googleLoginsCount =>
      _audienceLog.where((r) => r.method.toLowerCase().contains('google')).length;

  /// Кількість авторизацій через Email/Password
  int get emailPasswordLoginsCount =>
      _audienceLog.where((r) => r.method.toLowerCase().contains('email')).length;

  /// Симуляція тестового запису в аудиторію (для перевірки та презентації)
  Future<void> simulateTestAudienceMember({
    String email = 'test_student@stu.cn.ua',
    String displayName = 'Тестовий Студент',
    String method = 'google',
  }) async {
    await recordAudienceLogin(
      userId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      method: method,
    );
  }

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

  /// Реєстрація входу користувача та збір даних аудиторії (хто і як залогінився)
  Future<void> logLogin({
    String? loginMethod = 'email_password',
    String? userId,
    String? email,
    String? displayName,
    Map<String, Object>? parameters,
  }) async {
    final method = loginMethod ?? 'email_password';

    if (userId != null || email != null) {
      await recordAudienceLogin(
        userId: userId ?? email ?? 'unknown_user',
        email: email ?? userId ?? 'unknown_email',
        displayName: displayName,
        method: method,
      );
    }

    final params = <String, Object>{
      'method': method,
      'user_id': ?userId,
      'email': ?email,
      'display_name': ?displayName,
      ...?parameters,
    };

    await logEvent(
      name: 'login',
      parameters: params,
    );
  }

  /// Реєстрація створення нового облікового запису та збір даних аудиторії
  Future<void> logSignUp({
    String? signUpMethod = 'email_password',
    String? userId,
    String? email,
    String? displayName,
    Map<String, Object>? parameters,
  }) async {
    final method = signUpMethod ?? 'email_password';

    if (userId != null || email != null) {
      await recordAudienceLogin(
        userId: userId ?? email ?? 'unknown_user',
        email: email ?? userId ?? 'unknown_email',
        displayName: displayName,
        method: method,
      );
    }

    final params = <String, Object>{
      'method': method,
      'user_id': ?userId,
      'email': ?email,
      'display_name': ?displayName,
      ...?parameters,
    };

    await logEvent(
      name: 'sign_up',
      parameters: params,
    );
  }

  /// Реєстрація виходу з облікового запису (ручна дія)
  Future<void> logLogout() async {
    await logEvent(
      name: 'logout',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'user_id': ?_currentUserId,
      },
    );
    await setUserId(null);
    _userProperties.remove('auth_method');
  }

  /// Реєстрація оновлення даних профілю (ручна дія: ім'я, фото)
  Future<void> logProfileUpdate({required String field, String? value}) async {
    final params = <String, Object>{'field': field};
    if (value != null) {
      params['value'] = value;
      if (field == 'display_name') {
        await setUserProperty(name: 'display_name', value: value);
      }
    }
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
    _audienceLog.clear();
  }
}
