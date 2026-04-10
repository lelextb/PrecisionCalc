import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/sound_manager.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  SettingsBloc(this.prefs) : super(SettingsState(
    themeMode: _getThemeModeFromString(prefs.getString('themeMode') ?? 'system'),
    locale: Locale(prefs.getString('locale') ?? 'en'),
    hapticEnabled: prefs.getBool('haptic') ?? true,
    soundEnabled: prefs.getBool('sound') ?? false,
  )) {
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLocale>(_onChangeLocale);
    on<ToggleHaptic>(_onToggleHaptic);
    on<ToggleSound>(_onToggleSound);
  }

  static ThemeMode _getThemeModeFromString(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  void _onChangeTheme(ChangeTheme event, Emitter<SettingsState> emit) {
    final modeStr = event.mode.toString().split('.').last;
    prefs.setString('themeMode', modeStr);
    emit(state.copyWith(themeMode: event.mode));
  }

  void _onChangeLocale(ChangeLocale event, Emitter<SettingsState> emit) {
    prefs.setString('locale', event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }

  void _onToggleHaptic(ToggleHaptic event, Emitter<SettingsState> emit) {
    prefs.setBool('haptic', !state.hapticEnabled);
    emit(state.copyWith(hapticEnabled: !state.hapticEnabled));
  }

  void _onToggleSound(ToggleSound event, Emitter<SettingsState> emit) {
    final newValue = !state.soundEnabled;
    prefs.setBool('sound', newValue);
    SoundManager().setEnabled(newValue);
    emit(state.copyWith(soundEnabled: newValue));
  }
}