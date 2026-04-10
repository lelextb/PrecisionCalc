import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          loc.translate('settings'),
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest,
              colorScheme.surface,
            ],
          ),
        ),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 20),
              children: [
                _buildGlassSection(
                  title: loc.translate('language'),
                  children: [_buildLanguageTile(context, state, loc)],
                ),
                _buildGlassSection(
                  title: loc.translate('theme'),
                  children: [_buildThemeTile(context, state, loc)],
                ),
                _buildGlassSection(
                  title: 'INTERACTION',
                  children: [
                    _buildSwitchTile(
                      icon: Icons.vibration_rounded,
                      title: loc.translate('haptic_feedback'),
                      value: state.hapticEnabled,
                      onChanged: (_) => context.read<SettingsBloc>().add(ToggleHaptic()),
                    ),
                    _buildSwitchTile(
                      icon: Icons.volume_up_rounded,
                      title: loc.translate('sound_effects'),
                      value: state.soundEnabled,
                      onChanged: (_) => context.read<SettingsBloc>().add(ToggleSound()),
                    ),
                  ],
                ),
                _buildGlassSection(
                  title: loc.translate('about'),
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                      title: Text(loc.translate('version')),
                      trailing: Text(
                        'v$_version',
                        style: const TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassSection({required String title, required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8, top: 16),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              letterSpacing: 2,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildLanguageTile(BuildContext context, SettingsState state, AppLocalizations loc) {
    return ListTile(
      leading: Icon(Icons.translate_rounded, color: Theme.of(context).colorScheme.primary),
      title: Text(loc.translate('language')),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: state.locale,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          items: const [
            DropdownMenuItem(value: Locale('en'), child: Text('English')),
            DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
          ],
          onChanged: (locale) {
            if (locale != null) context.read<SettingsBloc>().add(ChangeLocale(locale));
          },
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, SettingsState state, AppLocalizations loc) {
    return ListTile(
      leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary),
      title: Text(loc.translate('theme')),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<ThemeMode>(
          value: state.themeMode,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          items: [
            DropdownMenuItem(value: ThemeMode.system, child: Text(loc.translate('system'))),
            DropdownMenuItem(value: ThemeMode.light, child: Text(loc.translate('light'))),
            DropdownMenuItem(value: ThemeMode.dark, child: Text(loc.translate('dark'))),
          ],
          onChanged: (mode) {
            if (mode != null) context.read<SettingsBloc>().add(ChangeTheme(mode));
          },
        ),
      ),
    );
  }
}