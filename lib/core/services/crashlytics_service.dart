import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Модель запису про помилку для журналу Crashlytics
class CrashReport {
  final DateTime timestamp;
  final String error;
  final String? stackTrace;
  final String? reason;
  final bool fatal;

  const CrashReport({
    required this.timestamp,
    required this.error,
    this.stackTrace,
    this.reason,
    required this.fatal,
  });

  Map<String, dynamic> toMap() => {
    'timestamp': timestamp.toIso8601String(),
    'error': error,
    'stackTrace': stackTrace,
    'reason': reason,
    'fatal': fatal,
  };
}

/// Сервіс моніторингу стабільності та перехоплення помилок (Crashlytics).
/// Відповідає вимогам Завдання 2 (стор. 8, 14 методички).
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  static CrashlyticsService get instance => _instance;

  final List<CrashReport> _reports = [];
  final List<String> _breadcrumbs = [];

  List<CrashReport> get reports => List.unmodifiable(_reports);
  List<String> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  /// Додавання текстового повідомлення до журналу сеансу
  Future<void> log(String message) async {
    final entry = '[${DateTime.now().toIso8601String()}] $message';
    _breadcrumbs.add(entry);
    developer.log(entry, name: 'CrashlyticsLog');
  }

  /// Реєстрація помилки (fatal чи non-fatal)
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    final report = CrashReport(
      timestamp: DateTime.now(),
      error: exception.toString(),
      stackTrace: stack?.toString(),
      reason: reason?.toString(),
      fatal: fatal,
    );
    _reports.add(report);

    // ignore: avoid_print
    print('💥 [Crashlytics ${fatal ? "FATAL" : "NON-FATAL"}] Reason: $reason | Error: $exception');
    if (stack != null) {
      // ignore: avoid_print
      print('StackTrace:\n$stack');
    }

    developer.log(
      '💥 [Crashlytics ${fatal ? "FATAL" : "NON-FATAL"}] Reason: $reason | Error: $exception',
      name: 'CrashlyticsService',
      error: exception,
      stackTrace: stack,
    );
  }

  /// Ініціалізація глобальних обробників перехоплення помилок Flutter та Dart
  void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      recordError(
        details.exception,
        details.stack,
        reason: details.context?.toString() ?? 'Flutter framework error',
        fatal: false,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(
        error,
        stack,
        reason: 'Uncaught platform/isolate error',
        fatal: true,
      );
      return true;
    };
  }

  /// Генерація тестової помилки для перевірки звіту в Crashlytics (Завдання 2)
  void simulateTestCrash({bool fatal = false}) {
    try {
      throw StateError(
        'Тестова помилка для перевірки Crashlytics у Лабораторній роботі №4 (AutoLog)',
      );
    } catch (e, stack) {
      recordError(
        e,
        stack,
        reason: 'Ручне тестування інтеграції звітування про збої',
        fatal: fatal,
      );
    }
  }
}
