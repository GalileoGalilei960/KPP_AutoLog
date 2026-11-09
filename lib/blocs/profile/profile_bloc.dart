import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/crashlytics_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/settings_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final SettingsRepository settingsRepository;

  ProfileBloc({
    required this.authRepository,
    required this.settingsRepository,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateDisplayNameEvent>(_onUpdateDisplayName);
    on<UpdatePhotoUrlEvent>(_onUpdatePhotoUrl);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<ChangePasswordEvent>(_onChangePassword);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = authRepository.currentUser;
      final settings = await settingsRepository.getSettings();
      emit(ProfileLoaded(user: user, settings: settings));
    } catch (e) {
      emit(ProfileError('Не вдалося завантажити профіль: $e'));
    }
  }

  Future<void> _onUpdateDisplayName(
    UpdateDisplayNameEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await authRepository.updateDisplayName(event.displayName);
      await AnalyticsService.instance.logProfileUpdate(field: 'display_name');
      final settings = await settingsRepository.getSettings();
      emit(ProfileLoaded(
        user: authRepository.currentUser,
        settings: settings,
        successMessage: "Ім'я успішно оновлено",
      ));
    } catch (e) {
      emit(ProfileError('Не вдалося оновити імʼя: $e'));
    }
  }

  Future<void> _onUpdatePhotoUrl(
    UpdatePhotoUrlEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await authRepository.updatePhotoUrl(event.photoUrl);
      await AnalyticsService.instance.logProfileUpdate(field: 'photo_url');
      final settings = await settingsRepository.getSettings();
      emit(ProfileLoaded(
        user: authRepository.currentUser,
        settings: settings,
        successMessage: 'Фото профілю оновлено',
      ));
    } catch (e) {
      emit(ProfileError('Не вдалося оновити фото: $e'));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await settingsRepository.saveSettings(event.settings);
      emit(ProfileLoaded(
        user: authRepository.currentUser,
        settings: event.settings,
        successMessage: 'Налаштування збережено локально',
      ));
    } catch (e) {
      emit(ProfileError('Не вдалося зберегти налаштування: $e'));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await authRepository.updatePassword(
        newPassword: event.newPassword,
        currentPassword: event.currentPassword,
      );
      await AnalyticsService.instance.logPasswordChange();
      final settings = await settingsRepository.getSettings();
      emit(ProfileLoaded(
        user: authRepository.currentUser,
        settings: settings,
        successMessage: 'Пароль успішно змінено',
      ));
    } on AuthException catch (e) {
      emit(ProfileError(e.message));
    } catch (e, stack) {
      CrashlyticsService.instance.recordError(
        e,
        stack,
        reason: 'Password change error in ProfileBloc',
        fatal: false,
      );
      emit(const ProfileError('Помилка при зміні пароля'));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await AnalyticsService.instance.logLogout();
      await authRepository.signOut();
      emit(const ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError('Помилка при виході: $e'));
    }
  }
}
