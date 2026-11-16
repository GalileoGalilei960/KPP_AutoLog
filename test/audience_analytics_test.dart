import 'package:flutter_test/flutter_test.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/core/services/analytics_service.dart';

void main() {
  setUp(() {
    AnalyticsService.instance.clearLogs();
  });

  group('Audience & Login Analytics Tests (Збірка аудієнції)', () {
    test('1. logLogin records user audience properties and methods', () async {
      await AnalyticsService.instance.logLogin(
        loginMethod: 'email_password',
        userId: 'user_123',
        email: 'student@example.com',
        displayName: 'Іван Франко',
      );

      final audience = AnalyticsService.instance.audienceLog;
      expect(audience.length, equals(1));
      expect(audience.first.userId, equals('user_123'));
      expect(audience.first.email, equals('student@example.com'));
      expect(audience.first.displayName, equals('Іван Франко'));
      expect(audience.first.method, equals('email_password'));

      // Перевірка Firebase User Properties
      final props = AnalyticsService.instance.userProperties;
      expect(props['user_id'], equals('user_123'));
      expect(props['email'], equals('student@example.com'));
      expect(props['email_domain'], equals('example.com'));
      expect(props['auth_method'], equals('email_password'));
      expect(props['platform'], equals('linux'));
      expect(props['display_name'], equals('Іван Франко'));
    });

    test('2. Multiple logins segment Google vs Email users in audience', () async {
      await AnalyticsService.instance.logLogin(
        loginMethod: 'google',
        userId: 'google_456',
        email: 'google_user@gmail.com',
        displayName: 'Google Користувач',
      );

      await AnalyticsService.instance.logLogin(
        loginMethod: 'email_password',
        userId: 'email_789',
        email: 'email_user@stu.cn.ua',
        displayName: 'Email Користувач',
      );

      expect(AnalyticsService.instance.audienceLog.length, equals(2));
      expect(AnalyticsService.instance.googleLoginsCount, equals(1));
      expect(AnalyticsService.instance.emailPasswordLoginsCount, equals(1));
      expect(AnalyticsService.instance.uniqueAudience.length, equals(2));
    });

    test('3. logLogout clears current userId and resets active session', () async {
      await AnalyticsService.instance.logLogin(
        loginMethod: 'email_password',
        userId: 'active_user',
        email: 'active@autoservice.ua',
      );

      expect(AnalyticsService.instance.currentUserId, equals('active_user'));

      await AnalyticsService.instance.logLogout();

      expect(AnalyticsService.instance.currentUserId, isNull);
      // Але історичний запис в аудиторії залишається для статистики
      expect(AnalyticsService.instance.audienceLog.isNotEmpty, isTrue);
    });

    test('4. simulateTestAudienceMember adds test record to audience log', () async {
      await AnalyticsService.instance.simulateTestAudienceMember(
        email: 'demo@stu.cn.ua',
        displayName: 'Демо Студент',
        method: 'google',
      );

      expect(AnalyticsService.instance.audienceLog.length, equals(1));
      expect(AnalyticsService.instance.audienceLog.first.email, equals('demo@stu.cn.ua'));
      expect(AnalyticsService.instance.audienceLog.first.method, equals('google'));
    });
  });
}
