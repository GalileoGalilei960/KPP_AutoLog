import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

// Початковий екран за замовчуванням (можна змінити на AppRoutes.home)
const String defaultInitialRoute = AppRoutes.login;

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Підтримка збірки з прапорцем: --dart-define=route=/home
  const envRoute = String.fromEnvironment('route');

  // 2. Підтримка аргументів термінала: --route=/home або просто /home
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

  // 3. Зчитування маршруту з платформи (браузер / Deep Link)
  final platformRoute =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName;
  final effectivePlatformRoute =
      (platformRoute != '/' && platformRoute.isNotEmpty) ? platformRoute : null;

  final resolvedRoute = envRoute.isNotEmpty
      ? envRoute
      : (cliRoute ?? effectivePlatformRoute ?? defaultInitialRoute);

  runApp(AutoLogApp(initialRoute: resolvedRoute));
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
