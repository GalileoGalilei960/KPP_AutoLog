import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/main.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/screens/auth/login_screen.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/screens/auth/register_screen.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/screens/shell/main_layout.dart';

void main() {
  testWidgets('Full flow smoke test: Login -> Home -> Profile -> Logout',
      (WidgetTester tester) async {
    // Set desktop screen size for layout testing
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const AutoLogApp());
    expect(find.text('AutoLog'), findsOneWidget);
    expect(find.text('Увійти'), findsWidgets);

    // Navigate to Register screen
    await tester.tap(find.text('Немає акаунта? Зареєструватися'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Створення акаунту'), findsOneWidget);

    // Return to Login
    await tester.tap(find.text('Вже є акаунт? Увійти'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    // Login directly to Dashboard
    await tester.tap(find.widgetWithText(ElevatedButton, 'Увійти'));
    await tester.pumpAndSettle();
    expect(find.byType(MainLayout), findsOneWidget);
    expect(find.text('Головна панель'), findsOneWidget);
    expect(find.text('Volkswagen Golf'), findsOneWidget);
    expect(find.text('Потребує уваги'), findsOneWidget);

    // Switch to Profile Tab
    await tester.tap(find.text('Профіль'));
    await tester.pumpAndSettle();
    expect(find.text('Профіль та Безпека'), findsOneWidget);
    expect(find.text('Галадій Остап'), findsOneWidget);
    expect(find.text('ostaphaladii@gmail.com'), findsOneWidget);
    expect(find.text('Безпека'), findsOneWidget);

    // Logout
    await tester.tap(find.text('Вийти з акаунта'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Deep link to /profile directly opens Profile screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const AutoLogApp(initialRoute: '/profile'));
    await tester.pumpAndSettle();

    expect(find.byType(MainLayout), findsOneWidget);
    expect(find.text('Профіль та Безпека'), findsOneWidget);
    expect(find.text('Галадій Остап'), findsOneWidget);
  });

  testWidgets('Deep link to /garage opens Garage tab in MainLayout',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const AutoLogApp(initialRoute: '/garage'));
    await tester.pumpAndSettle();

    expect(find.byType(MainLayout), findsOneWidget);
    expect(find.text('Гараж автомобілів'), findsOneWidget);
  });

  testWidgets('Deep link to /register opens Register screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const AutoLogApp(initialRoute: '/register'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Створення акаунту'), findsOneWidget);
  });
}
