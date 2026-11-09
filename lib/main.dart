import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/garage/garage_bloc.dart';
import 'blocs/garage/garage_event.dart';
import 'blocs/history/history_bloc.dart';
import 'blocs/history/history_event.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/profile/profile_event.dart';
import 'core/auth/auth_scope.dart';
import 'core/routes/app_routes.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/firebase_auth_rest_repository.dart';
import 'data/repositories/maintenance_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/vehicles_repository.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  CrashlyticsService.instance.initialize();

  final AuthRepository authRepository = FirebaseAuthRestRepository();
  await authRepository.initialize();

  final authController = AuthController(repository: authRepository);

  await AnalyticsService.instance.logEvent(
    name: 'app_open',
    parameters: {
      'platform': 'linux',
      'is_authenticated': authRepository.isAuthenticated,
    },
  );

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
  final defaultStartRoute = authRepository.isAuthenticated
      ? AppRoutes.home
      : AppRoutes.login;

  final resolvedRoute = envRoute.isNotEmpty
      ? envRoute
      : (cliRoute ?? effectivePlatformRoute ?? defaultStartRoute);

  // Створюємо всі репозиторії в main() — поза деревом віджетів,
  // щоб уникнути помилки "Tried to listen to an InheritedWidget in a
  // life-cycle that will never be called again"
  final vehiclesRepository = LocalVehiclesRepository();
  final maintenanceRepository = LocalMaintenanceRepository();
  final settingsRepository = LocalSettingsRepository();

  runApp(
    AuthScope(
      repository: authRepository,
      controller: authController,
      child: AutoLogApp(
        initialRoute: resolvedRoute,
        vehiclesRepository: vehiclesRepository,
        maintenanceRepository: maintenanceRepository,
        settingsRepository: settingsRepository,
        authRepository: authRepository,
      ),
    ),
  );
}

class AutoLogApp extends StatelessWidget {
  final String initialRoute;
  final VehiclesRepository vehiclesRepository;
  final MaintenanceRepository maintenanceRepository;
  final SettingsRepository settingsRepository;
  final AuthRepository authRepository;

  const AutoLogApp({
    super.key,
    this.initialRoute = AppRoutes.login,
    required this.vehiclesRepository,
    required this.maintenanceRepository,
    required this.settingsRepository,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GarageBloc>(
          create: (_) => GarageBloc(
            vehiclesRepository: vehiclesRepository,
          )..add(const LoadVehicles()),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(
            maintenanceRepository: maintenanceRepository,
          )..add(const LoadRecords()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            authRepository: authRepository,
            settingsRepository: settingsRepository,
          )..add(const LoadProfile()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AutoLog',
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onGenerateInitialRoutes: (String initialRouteName) {
          return [
            AppRoutes.onGenerateRoute(RouteSettings(name: initialRouteName)),
          ];
        },
      ),
    );
  }
}
