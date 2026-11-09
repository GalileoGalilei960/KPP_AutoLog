import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/core/auth/auth_scope.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/core/routes/app_routes.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/models/auth_user.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/repositories/auth_repository.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/repositories/maintenance_repository.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/repositories/settings_repository.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/data/repositories/vehicles_repository.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/main.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/screens/auth/login_screen.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/screens/auth/register_screen.dart';
import 'package:kpp_haladii_ostap_opt_3_autoservice/screens/shell/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Тестовий Auth-репозиторій: починає з автентифікованим юзером
class _TestAuthRepository implements AuthRepository {
  final _ctrl = StreamController<AuthUser?>.broadcast();
  AuthUser? _user = const AuthUser(
    uid: 'test_uid',
    email: 'ostaphaladii@gmail.com',
    displayName: 'Галадій Остап',
  );

  @override
  Stream<AuthUser?> get authStateChanges => _ctrl.stream;
  @override
  AuthUser? get currentUser => _user;
  @override
  bool get isAuthenticated => _user != null;
  @override
  Future<void> initialize() async {}

  @override
  Future<void> signIn({required String email, required String password}) async {
    _user = AuthUser(uid: 'test_uid', email: email, displayName: 'Галадій Остап');
    _ctrl.add(_user);
  }

  @override
  Future<void> signInWithGoogle({
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    _user = AuthUser(
      uid: 'test_uid',
      email: email ?? 'ostaphaladii@gmail.com',
      displayName: displayName ?? 'Галадій Остап',
      photoUrl: photoUrl,
    );
    _ctrl.add(_user);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _user = AuthUser(
      uid: 'test_uid',
      email: email,
      displayName: displayName ?? 'Галадій Остап',
    );
    _ctrl.add(_user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updateDisplayName(String name) async {
    _user = _user?.copyWith(displayName: name);
    _ctrl.add(_user);
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    _user = _user?.copyWith(photoUrl: photoUrl);
    _ctrl.add(_user);
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    String? currentPassword,
  }) async {}

  @override
  Future<void> signOut() async {
    _user = null;
    _ctrl.add(null);
  }
}

/// Допоміжна функція для тестів — огортає AutoLogApp в AuthScope
Widget buildTestApp({String initialRoute = AppRoutes.login}) {
  final authRepo = _TestAuthRepository();
  final authController = AuthController(repository: authRepo);
  return AuthScope(
    repository: authRepo,
    controller: authController,
    child: AutoLogApp(
      initialRoute: initialRoute,
      authRepository: authRepo,
      vehiclesRepository: LocalVehiclesRepository(),
      maintenanceRepository: LocalMaintenanceRepository(),
      settingsRepository: LocalSettingsRepository(),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Full flow smoke test: Login -> Home -> Profile -> Logout',
      (WidgetTester tester) async {
    // Set desktop screen size for layout testing
    tester.view.physicalSize = const Size(1280, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp());
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
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'ostaphaladii@gmail.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Пароль'),
      'password123',
    );
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
    await tester.ensureVisible(find.text('Вийти з акаунта'));
    await tester.tap(find.text('Вийти з акаунта'));
    await tester.pumpAndSettle();
    // Confirm dialog
    expect(find.text('Вихід із системи'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Вийти'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Deep link to /profile directly opens Profile screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp(initialRoute: '/profile'));
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

    await tester.pumpWidget(buildTestApp(initialRoute: '/garage'));
    await tester.pumpAndSettle();

    expect(find.byType(MainLayout), findsOneWidget);
    expect(find.text('Гараж автомобілів'), findsOneWidget);
  });

  testWidgets('Deep link to /register opens Register screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestApp(initialRoute: '/register'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Створення акаунту'), findsOneWidget);
  });
}
