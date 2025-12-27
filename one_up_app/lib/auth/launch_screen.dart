import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:one_up_app/api_service/api_response.dart';
import 'package:one_up_app/api_service/api_end_points.dart';
import 'package:one_up_app/api_service/dio_client.dart';
import 'package:one_up_app/auth/login_screen.dart';
import 'package:one_up_app/main_ui/dashboard_screen.dart';
import 'package:one_up_app/utils/app_preferences.dart';
import 'package:one_up_app/utils/common_utilies.dart';
import 'package:one_up_app/utils/constants.dart';
import 'package:one_up_app/utils/image_path.dart';
import '../api_service/web_client.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> with WidgetsBindingObserver {
  late ApiResponse apiResponse;
  bool _navigated = false; // ✅ Prevent multiple navigations

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppPreferences.init();
    // checkPermission();
    _initFCMToken();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  Future<void> _initFCMToken() async {
    String? savedToken = AppPreferences.getFCMToken();
    if (savedToken == null) {
      log("🔹 No FCM token found, generating new one...");
      String? newToken = await FirebaseMessaging.instance.getToken();

      if (newToken != null) {
        log("✅ New FCM Token: $newToken");
        await AppPreferences.setFCMToken(newToken);
      }
    } else {
      log("✅ FCM Token already exists: $savedToken");
    }

    // Proceed to next screen after small delay
    checkPermission();
  }
  /// ✅ Handle app lifecycle (foreground/background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_navigated) {
      // If app resumes, continue flow only if not navigated yet
      goToMainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Image(
                image: AssetImage(appLogo),
                width: 180,
                height: 100,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                'v$version',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'Lato',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> getAndroidSdkInt() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return null;
  }

  Future<void> checkPermission() async {
    if (!Platform.isAndroid) {
      goToMainScreen();
      return;
    }

    final sdkInt = await getAndroidSdkInt() ?? 0;

    if (sdkInt >= 33) {
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        final newStatus = await Permission.notification.request();
        if (newStatus.isPermanentlyDenied) {
          await openAppSettings();
          return;
        }
      }

      // Then request photo/media permission
      final statuses = await [Permission.photos].request();
      if (statuses[Permission.photos]?.isGranted == true) {
        goToMainScreen();
      } else if (statuses[Permission.photos]?.isPermanentlyDenied == true) {
        await openAppSettings();
      }

    } else {
      // For Android 12 and below, handle storage + notification differently
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        final newStatus = await Permission.notification.request();
        if (newStatus.isPermanentlyDenied) {
          await openAppSettings();
          return;
        }
      }

      if (await Permission.storage.isGranted) {
        goToMainScreen();
      } else {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          goToMainScreen();
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      }
    }
  }

  void goToMainScreen() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      if (AppPreferences.getIsLogin()) {
        await verifyToken();
      } else {
        _navigateTo(const LoginScreen());
      }
    });
  }


  Future<void> verifyToken() async {
    final formData = jsonEncode({
      "id": AppPreferences.getToken(),
    });

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.verifyToken,
        payload: formData,
        method: MethodType.post,
      );

      if (!mounted) return;

      if (response.status == "200" || response.status == "201") {
        if (response.data["status"] == 200 || response.data["status"] == 201) {
          final map = jsonDecode(AppPreferences.getUserSession());
          _navigateTo(DashboardScreen(isAdmin: map['isAdmin']));
        } else {
          _navigateTo(const LoginScreen());
        }
      } else {
        _navigateTo(const LoginScreen());
      }
    } catch (e) {
      log("Error: ${e.toString()}");
      _navigateTo(const LoginScreen());
    } finally {
      if (mounted) {
        CommonUtilities.hideLoadingDialog(context);
      }
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted || _navigated) return; // prevent multiple calls
    _navigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => screen),
            (route) => false,
      );
    });
  }

}

