import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_up_app/auth/launch_screen.dart';
import 'package:one_up_app/auth/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide status and navigation bars
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [
      SystemUiOverlay.top,    // Shows the status bar
      SystemUiOverlay.bottom, // Shows the navigation bar
    ], // Or light
  );
  // callWarmUpAPi();
  runApp(
    DevicePreview(
    enabled: !kReleaseMode, // Enable only in debug mode
    builder: (context) => const MyApp(),
  ),);
}

/*void callWarmUpAPi() async{
  final response = await DioClient().request(
    path: "",
    method: MethodType.get,
  );
}*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One up',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: 'launch_screen',
      routes:{
        'launch_screen': (context) => LaunchScreen(),
        '/login': (context)=> LoginScreen()
      },
      // themeMode: AppPreference.getIsDark()?ThemeMode.dark:ThemeMode.light,
      // theme: ThemeDataStyle.light, // Light/Default mode styles
      // darkTheme: ThemeDataStyle.dark,
      home: const LaunchScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          children: [
          ],
        ),
      ),
    );
  }
}