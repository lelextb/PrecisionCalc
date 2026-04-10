import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'l10n/app_localizations.dart';
import 'core/database/database.dart';
import 'core/utils/theme_manager.dart';
import 'features/calculator/presentation/bloc/calculator_bloc.dart';
import 'features/calculator/presentation/pages/calculator_page.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Logger('FlutterError').severe(details.exceptionAsString());
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Logger('PlatformError').severe(error, stack);
    return true;
  };

  await AppDatabase.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  runApp(CalcArchitectApp(prefs: prefs));
}

class CalcArchitectApp extends StatelessWidget {
  final SharedPreferences prefs;
  const CalcArchitectApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CalculatorBloc()),
        BlocProvider(create: (_) => SettingsBloc(prefs)),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Calc Architect',
            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: state.themeMode,
            locale: state.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: const CalculatorPage(),
          );
        },
      ),
    );
  }
}