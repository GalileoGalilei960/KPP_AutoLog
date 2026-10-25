import 'package:flutter/material.dart';

import 'core/auth/auth_scope.dart';
import 'core/routes/app_routes.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/firebase_auth_rest_repository.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Ініціалізація сервісу відстеження збоїв (Firebase Crashlytics, Завдання 2)
  CrashlyticsService.instance.initialize();

  // 2. Ініціалізація репозиторію автентифікації та відновлення сеансу (Завдання 4)
  final AuthRepository authRepository = FirebaseAuthRestRepository();
  await authRepository.initialize();

  final authController = AuthController(repository: authRepository);

  // 3. Реєстрація запуску застосунку в сервісі аналітики (Firebase Analytics, Завдання 1)
  await AnalyticsService.instance.logEvent(
    name: 'app_open',
    parameters: {
      'platform': 'linux',
      'is_authenticated': authRepository.isAuthenticated,
    },
  );

  // 4. Визначення початкового маршруту з урахуванням статусу входу та deep-linking
  const envRoute = String.fromEnvironment('route');
  String? cliRoute;
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('--route=')) {
      cliRoute = arg.substring('--route='.length);
    } else if (arg == '--route' && i + 1 < args.length) {
      cliRoute = args[i + 1];
    } else if (arg.startsWith('/')) {
      cliRoute = arg;
    }
  }

  final platformRoute =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  final effectivePlatformRoute =
      (platformRoute != '/' && platformRoute.isNotEmpty) ? platformRoute : null;

  // Якщо користувач уже увійшов — відкриваємо home, інакше екран логіну
  final defaultStartRoute =
      authRepository.isAuthenticated ? AppRoutes.home : AppRoutes.login;

  final resolvedRoute = envRoute.isNotEmpty
      ? envRoute
      : (cliRoute ?? effectivePlatformRoute ?? defaultStartRoute);

  runApp(
    AuthScope(
      repository: authRepository,
      controller: authController,
      child: AutoLogApp(initialRoute: resolvedRoute),
    ),
  );
}

class AutoLogApp extends StatelessWidget {
  final String initialRoute;

  const AutoLogApp({
    super.key,
    this.initialRoute = AppRoutes.login,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoLog',
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onGenerateInitialRoutes: (String initialRouteName) {
        return [
          AppRoutes.onGenerateRoute(
            RouteSettings(name: initialRouteName),
          ),
        ];
      },
    );
  }
}
