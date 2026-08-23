import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taboor/core/services/theme_service.dart';
import 'package:taboor/core/services/locale_service.dart';
import 'package:taboor/core/themes/app_theme.dart';
import 'package:taboor/core/utils/navigation_service.dart';
import 'package:taboor/core/utils/shared_prefs.dart';
import 'package:taboor/features/splash/presentation/screens/splash_screen.dart';
import 'package:taboor/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SharedPrefs.init();
  await ThemeService.init();

  runApp(const TaboorApp());
}

class TaboorApp extends StatelessWidget {
  const TaboorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LocaleService.localeNotifier,
          builder: (context, locale, child) {
            return MaterialApp(
              title: 'Taboor',
              debugShowCheckedModeBanner: false,
              navigatorKey: NavigationService.navigatorKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}