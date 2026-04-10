import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pet_finder/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app/router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/hive_local_datasource.dart';
import 'firebase_options.dart';
import 'injection_container.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/post/post_bloc.dart';

/// Global notifier so any widget can switch locale at runtime.
final localeNotifier = ValueNotifier<Locale>(const Locale('vi'));

/// Clears Firebase auth session on fresh install.
/// On iOS, Keychain persists across app deletions, so Firebase keeps the user
/// signed in even after the app is uninstalled and reinstalled.
Future<void> _clearAuthOnFreshInstall() async {
  final prefs = await SharedPreferences.getInstance();
  const launchKey = 'app_has_launched_before';
  final hasLaunchedBefore = prefs.getBool(launchKey) ?? false;

  if (!hasLaunchedBefore) {
    await FirebaseAuth.instance.signOut();
    await prefs.setBool(launchKey, true);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveLocalDataSource.init();
  AppConstants.validateCloudinaryConfig();
  await configureDependencies();

  await _clearAuthOnFreshInstall(); // Thêm TRƯỚC runApp

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString(AppConstants.keyLanguage) ?? 'vi';
  localeNotifier.value = Locale(langCode);

  runApp(const PetFinderApp());
}

class PetFinderApp extends StatelessWidget {
  const PetFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<PostBloc>(create: (_) => sl<PostBloc>()),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: localeNotifier,
        builder: (_, locale, __) => MaterialApp.router(
          title: 'PetFinder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          locale: locale,
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi', 'VN'),
            Locale('en', 'US'),
          ],
        ),
      ),
    );
  }
}
