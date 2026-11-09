class UserSettings {
  final String currency; // 'UAH', 'USD', 'EUR'
  final String distanceUnit; // 'km', 'miles'

  const UserSettings({
    this.currency = 'UAH',
    this.distanceUnit = 'km',
  });

  UserSettings copyWith({
    String? currency,
    String? distanceUnit,
  }) {
    return UserSettings(
      currency: currency ?? this.currency,
      distanceUnit: distanceUnit ?? this.distanceUnit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'distanceUnit': distanceUnit,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      currency: json['currency'] as String? ?? 'UAH',
      distanceUnit: json['distanceUnit'] as String? ?? 'km',
    );
  }
}
