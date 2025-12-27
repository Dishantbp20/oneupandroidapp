import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:one_up_app/auth/sign_up_screen.dart';
import 'package:one_up_app/main_ui/dashboard_screen.dart';
import 'package:one_up_app/utils/app_preferences.dart';
import 'package:one_up_app/utils/colors.dart';
import 'package:one_up_app/utils/common_utilies.dart';
import 'package:one_up_app/widgets/styled_button.dart';
import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/constants.dart';
import '../utils/image_path.dart';
import '../widgets/top_curve_clipper.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final formKey = GlobalKey<FormState>();
  late ApiResponse apiResponse ;
  final playerIdCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    // checkPermission();
    _initFCMToken();
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
  }
  @override
  Widget build(BuildContext context) {
    AppPreferences.init();
    return Scaffold(
      body: Stack(
        children: [
          // Curved Background using ClipPath
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.getGradientColor(),begin: Alignment.topCenter, end:  Alignment.bottomCenter)
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage(appLogo),
                    width: 140,
                    height: 75,
                  ),
                  Text(
                    "Sports App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
          ),

          // Form content
          Container(
            margin: EdgeInsets.only(top: 200),
            child:  SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: Form(
                key: formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign in',
                    style: TextStyle(
                        fontSize: 15,fontFamily: 'Lato',
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Please login to continue using 1up sports app',
                    style: TextStyle(
                        fontSize: 14,fontFamily: 'Lato',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.normal,
                        color: AppColors.lightGrey.withAlpha(80)

                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Player ID field
                  Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(10),
                    child: TextFormField(
                      controller: playerIdCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter your Player ID",
                        hintStyle: TextStyle(
                            color: AppColors.lightGrey.withAlpha(80),
                          fontSize: 14
                        ),
                        prefixIcon: Icon(Icons.person, color: AppColors.lightGrey,),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(10),
                      child: TextFormField(
                        controller: passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "******************",
                          hintStyle: TextStyle(
                              color: AppColors.lightGrey.withAlpha(80),
                              fontSize: 14
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.lock, color: AppColors.lightGrey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.lightGrey.withAlpha(50),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),

                        ),
                      )
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                        /*CommonUtilities.showToast("Forgot password");*/
                      },
                      child: Text("Forgot password?", style: TextStyle(fontSize: 13),),
                    ),
                  ),
                  StyledButton(
                    text: "Sign in",
                    onPressed:(){
                      /*Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen(isAdmin: true,)),
                      );*/
                      FocusScope.of(context).unfocus();
                      submitForm();
                      // MaterialPageRoute()
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                            fontSize: 14,fontFamily: 'Lato'
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: Text("Sign up.",style: TextStyle(
                            fontSize: 14,fontFamily: 'Lato'
                        ),),
                      ),
                    ],
                  )
                ],
              ),)
            ),
          ),
        ],
      ),
    );

  }
  @override
  void dispose() {
    playerIdCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    log("On click sign in...");
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    CommonUtilities.showLoadingDialog(context);

    try {
      final loginResponse = await DioClient().request(
        path: ApiEndPoints.loginEndPoint,
        payload: {
          "playerId": playerIdCtrl.text,
          "password": passwordCtrl.text,
          "token": AppPreferences.getFCMToken()
        },
        method: MethodType.post,
      );

      log("✅ Login API Response: ${loginResponse.status} - ${loginResponse.message}");

      if (loginResponse.status == "200" || loginResponse.status == "201") {
        if (loginResponse.data["status"] == 200) {
          String token = loginResponse.data["data"];
          AppPreferences.setIsLogin(true);
          AppPreferences.setToken(token);

          // ✅ Hide loader before navigating
          CommonUtilities.hideLoadingDialog(context);

          // 🚀 Navigate immediately (optimistic navigation)


          // 🔄 Fetch session data silently in background
          getUserSessionData(token);
        } else {
          CommonUtilities.hideLoadingDialog(context);
          CommonUtilities.showAlertDialog(
            context,
            message: loginResponse.data['message'],
            icon: Icon(Icons.warning_amber, color: Colors.red, size: 50),
          );
        }
      } else {
        CommonUtilities.hideLoadingDialog(context);
        CommonUtilities.showAlertDialog(
          context,
          message: loginResponse.data['message'],
          icon: Icon(Icons.warning_amber, color: Colors.red, size: 50),
        );
      }
    } catch (e) {
      log("❌ Login Error: ${e.toString()}");
      CommonUtilities.hideLoadingDialog(context);
      CommonUtilities.showAlertDialog(
        context,
        message: e.toString(),
        icon: Icon(Icons.warning_amber, color: Colors.red, size: 50),
      );
    }
  }

  Future<void> getUserSessionData(String id) async {
    CommonUtilities.showLoadingDialog(context);
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getSessionByIdEndPoint + id,
        method: MethodType.get,
      );

      log("✅ Session API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data["status"] == 200) {
          String data = jsonEncode(response.data["data"]);
          AppPreferences.setUserSession(data);
          AppPreferences.setIsAdmin(response.data["data"]["isAdmin"]);
          CommonUtilities.hideLoadingDialog(context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                // fallback, will be updated when session loads
                isAdmin: AppPreferences.getIsAdmin(),
              ),
            ),
          );
          log("User data saved: ${response.data["data"]}");
        } else {
          log("⚠️ Session API failed: ${response.data['message']}");
        }
      } else {
        log("⚠️ Session API failed: ${response.data['message']}");
      }
    } catch (e) {
      log("❌ Session API Error: ${e.toString()}");
    }
  }


}

