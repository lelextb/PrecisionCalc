// settings_event.dart
part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class ChangeTheme extends SettingsEvent {
  final ThemeMode mode;
  const ChangeTheme(this.mode);
  @override
  List<Object?> get props => [mode];
}

class ChangeLocale extends SettingsEvent {
  final Locale locale;
  const ChangeLocale(this.locale);
  @override
  List<Object?> get props => [locale];
}

class ToggleHaptic extends SettingsEvent {}
class ToggleSound extends SettingsEvent {}