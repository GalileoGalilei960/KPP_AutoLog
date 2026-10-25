import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/shell/main_layout.dart';

/// Centralized route definitions and route generator supporting Deep Linking.
class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String garage = '/garage';
  static const String history = '/history';
  static const String profile = '/profile';

  /// Generates routes dynamically based on incoming route settings / URI paths.
  /// Supports deep linking directly to specific app sections:
  /// - `/` or `/login` -> [LoginScreen]
  /// - `/register` -> [RegisterScreen]
  /// - `/home` -> [MainLayout] (Tab 0: Головна панель)
  /// - `/garage` -> [MainLayout] (Tab 1: Гараж)
  /// - `/history` -> [MainLayout] (Tab 2: Історія)
  /// - `/profile` -> [MainLayout] (Tab 3: Профіль та Безпека)
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    var rawName = settings.name ?? root;
    if (!rawName.startsWith('/')) {
      rawName = '/$rawName';
    }
    final uri = Uri.parse(rawName);

    switch (uri.path) {
      case root:
      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainLayout(initialIndex: 0),
        );
      case garage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainLayout(initialIndex: 1),
        );
      case history:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainLayout(initialIndex: 2),
        );
      case profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainLayout(initialIndex: 3),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
    }
  }
}

