import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_up_app/auth/launch_screen.dart';
import 'package:one_up_app/auth/login_screen.dart';
import 'package:one_up_app/firebase_options.dart';
import 'package:one_up_app/services/fcm_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only once
  await Firebase.initializeApp(
    name: 'One up notification',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM Service
  await FCMService.initialize();

  // Keep system UI visible
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  // Run app
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (_) => const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Up',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      // ✅ Do not use both home and initialRoute together
      initialRoute: '/launch',
      routes: {
        '/launch': (context) => const LaunchScreen(),
        '/login': (context) => const LoginScreen(),
      },
      // ✅ Set theme if you have one, or fallback to default
      theme: ThemeData.light(),
      // darkTheme: ThemeData.dark(),
      // themeMode: ThemeMode.system,
      // ✅ Required for DevicePreview (optional but helpful)
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}
