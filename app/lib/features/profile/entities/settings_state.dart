class SettingsState {
  final bool notificationsEnabled;
  final bool locationEnabled;

  const SettingsState({
    this.notificationsEnabled = true,
    this.locationEnabled = true,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? locationEnabled,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
    );
  }
}
