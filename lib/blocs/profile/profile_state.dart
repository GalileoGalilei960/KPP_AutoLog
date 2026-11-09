import '../../data/models/auth_user.dart';
import '../../data/models/user_settings.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final AuthUser? user;
  final UserSettings settings;
  final String? successMessage;

  const ProfileLoaded({
    required this.user,
    required this.settings,
    this.successMessage,
  });

  ProfileLoaded copyWith({
    AuthUser? user,
    UserSettings? settings,
    String? successMessage,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      settings: settings ?? this.settings,
      successMessage: successMessage,
    );
  }
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}
