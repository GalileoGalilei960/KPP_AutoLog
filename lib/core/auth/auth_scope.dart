import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

/// Модель стану авторизації на базі ChangeNotifier
class AuthController extends ChangeNotifier {
  final AuthRepository repository;
  StreamSubscription<AuthUser?>? _subscription;

  AuthUser? _currentUser;
  bool _isLoading = false;

  AuthController({required this.repository}) {
    _currentUser = repository.currentUser;
    _subscription = repository.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// InheritedNotifier для надання доступу до AuthController та AuthRepository по всьому дереву віджетів
class AuthScope extends InheritedNotifier<AuthController> {
  static AuthController? _fallbackController;

  final AuthRepository repository;

  const AuthScope({
    super.key,
    required this.repository,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    if (scope != null && scope.notifier != null) {
      return scope.notifier!;
    }
    // Fallback для standalone віджетів / тестів
    return _fallbackController ??= AuthController(
      repository: _DummyAuthRepository(),
    );
  }

  static AuthRepository repositoryOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    if (scope != null) {
      return scope.repository;
    }
    return of(context).repository;
  }
}

class _DummyAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _user = const AuthUser(
    uid: 'test_uid',
    email: 'ostaphaladii@gmail.com',
    displayName: 'Галадій Остап',
  );

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _user;

  @override
  bool get isAuthenticated => _user != null;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> signIn({required String email, required String password}) async {
    _user = const AuthUser(
      uid: 'test_uid',
      email: 'ostaphaladii@gmail.com',
      displayName: 'Галадій Остап',
    );
    _controller.add(_user);
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
    _controller.add(_user);
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
    _controller.add(_user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updateDisplayName(String name) async {
    _user = _user?.copyWith(displayName: name);
    _controller.add(_user);
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    _user = _user?.copyWith(photoUrl: photoUrl);
    _controller.add(_user);
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    String? currentPassword,
  }) async {}

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}
