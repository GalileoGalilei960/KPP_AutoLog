import '../../data/models/user_settings.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateDisplayNameEvent extends ProfileEvent {
  final String displayName;
  const UpdateDisplayNameEvent(this.displayName);
}

class UpdatePhotoUrlEvent extends ProfileEvent {
  final String photoUrl;
  const UpdatePhotoUrlEvent(this.photoUrl);
}

class UpdateSettingsEvent extends ProfileEvent {
  final UserSettings settings;
  const UpdateSettingsEvent(this.settings);
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}

class SignOutEvent extends ProfileEvent {
  const SignOutEvent();
}
