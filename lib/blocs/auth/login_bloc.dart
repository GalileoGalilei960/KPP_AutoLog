import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/crashlytics_service.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginSubmitted>(_onGoogleLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      await _authRepository.signIn(
        email: event.email.trim(),
        password: event.password,
      );
      AuthUser? user;
      try {
        user = _authRepository.currentUser;
      } catch (_) {}

      await AnalyticsService.instance.logLogin(
        loginMethod: 'email_password',
        userId: user?.uid ?? 'uid_${event.email.trim().hashCode.abs()}',
        email: user?.email ?? event.email.trim(),
        displayName: user?.displayName,
      );
      emit(const LoginSuccess());
    } on AuthException catch (e) {
      emit(LoginError(e.message));
    } catch (e, stack) {
      CrashlyticsService.instance.recordError(
        e,
        stack,
        reason: 'Login failed in LoginBloc',
        fatal: false,
      );
      emit(const LoginError('Сталася помилка при вході. Спробуйте пізніше.'));
    }
  }

  Future<void> _onGoogleLoginSubmitted(
    GoogleLoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      await _authRepository.signInWithGoogle();
      AuthUser? user;
      try {
        user = _authRepository.currentUser;
      } catch (_) {}

      await AnalyticsService.instance.logLogin(
        loginMethod: 'google',
        userId: user?.uid ?? 'google_uid_${DateTime.now().millisecondsSinceEpoch}',
        email: user?.email ?? 'google_user@gmail.com',
        displayName: user?.displayName ?? 'Google Користувач',
      );
      emit(const LoginSuccess());
    } on AuthException catch (e) {
      emit(LoginError(e.message));
    } catch (e, stack) {
      CrashlyticsService.instance.recordError(
        e,
        stack,
        reason: 'Google Login failed in LoginBloc',
        fatal: false,
      );
      emit(const LoginError('Не вдалося увійти через Google'));
    }
  }
}
