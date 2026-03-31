import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/update_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await ApiService.loadTokens();

  // Version check only for APK (not web — web always loads latest)
  String? updateUrl;
  if (!kIsWeb) {
    updateUrl = await ApiService.checkForUpdate();
  }

  runApp(NightPulseApp(forceUpdateUrl: updateUrl));
}

class NightPulseApp extends StatelessWidget {
  final String? forceUpdateUrl;

  const NightPulseApp({super.key, this.forceUpdateUrl});

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (forceUpdateUrl != null) {
      home = UpdateScreen(updateUrl: forceUpdateUrl!);
    } else if (ApiService.isLoggedIn) {
      home = const MainShell();
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NightPulse',
      theme: appTheme,
      home: home,
    );
  }
}
