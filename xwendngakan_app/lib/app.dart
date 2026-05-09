import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/institutions_provider.dart';
import 'providers/teachers_cv_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/news_provider.dart';
import 'providers/events_provider.dart';
import 'providers/connectivity_provider.dart';

/// Fallback delegate that provides English [MaterialLocalizations] for any
/// locale not covered by [GlobalMaterialLocalizations] (e.g. Kurdish "ku").
class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DefaultMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

/// Fallback delegate for [CupertinoLocalizations].
class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}

class XwendngakanApp extends StatelessWidget {
  const XwendngakanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) {
          final p = InstitutionsProvider();
          WidgetsBinding.instance.addPostFrameCallback((_) => p.init());
          return p;
        }),
        ChangeNotifierProvider(create: (_) => TeachersProvider()),
        ChangeNotifierProvider(create: (_) => CvProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const _MaterialAppShell(),
    );
  }
}

/// Keeps the [GoRouter] alive across locale / theme rebuilds.
/// Creating a new router on every build resets navigation to /splash,
/// so we store it in state and only initialise it once.
class _MaterialAppShell extends StatefulWidget {
  const _MaterialAppShell();

  @override
  State<_MaterialAppShell> createState() => _MaterialAppShellState();
}

class _MaterialAppShellState extends State<_MaterialAppShell> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    // Lazily create the router once; never recreate it on locale/theme change.
    _router ??= createRouter(context);

    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, theme, locale, _) {
        return MaterialApp.router(
          title: 'edu book',
          debugShowCheckedModeBanner: false,
          themeMode: theme.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: _router!,
          locale: locale.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            _FallbackMaterialLocalizationsDelegate(),
            _FallbackCupertinoLocalizationsDelegate(),
          ],
          builder: (context, child) {
            final isRTL = locale.isRTL;
            return Directionality(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}
