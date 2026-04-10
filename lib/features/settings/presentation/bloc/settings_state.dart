// settings_state.dart
part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool hapticEnabled;
  final bool soundEnabled;

  const SettingsState({
    required this.themeMode,
    required this.locale,
    required this.hapticEnabled,
    required this.soundEnabled,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? hapticEnabled,
    bool? soundEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, hapticEnabled, soundEnabled];
}