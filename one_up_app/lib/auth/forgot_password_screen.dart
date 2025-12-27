import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:one_up_app/api_service/dio_client.dart';
import 'package:one_up_app/widgets/custom_password_field.dart';
import 'package:one_up_app/widgets/custom_text_field.dart';

import '../api_service/api_end_points.dart';
import '../api_service/web_client.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/styled_button.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isUpdatePasswordView = false;
  final formKey = GlobalKey<FormState>();

  String otp = "";
  String userID = "";

  final emailCtrl = TextEditingController();
  final newPwdCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();

  final String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{6,20}$';

  /// central loader + error handler
  Future<T?> _executeWithLoader<T>(
      Future<T> Function() task, {
        bool showLoader = true,
      }) async {
    if (showLoader) CommonUtilities.showLoadingDialog(context);

    try {
      final result = await task();
      return result;
    } catch (e) {
      log("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
      return null;
    } finally {
      if (showLoader) CommonUtilities.hideLoadingDialog(context);
    }
  }

  /// validation methods
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!RegExp(passwordPattern).hasMatch(value)) {
      return 'Password must be 6–20 chars,\ninclude upper, lower, number & special char';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Confirm password is required";
    }
    if (value != newPwdCtrl.text) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUpdatePasswordView ? "Update Password" : "Forgot Password",
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontFamily: 'Lato'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: CustomAppBar(),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            isUpdatePasswordView ? updatePasswordView() : forgotPasswordView(),
          ],
        ),
      ),
    );
  }

  /// Forgot Password UI
  Widget forgotPasswordView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Enter your registered email Address"),
          const SizedBox(height: 8),
          CustomTextField(
            hint: "eg.john@doe.com",
            icon: Icons.email,
            textInputType: TextInputType.emailAddress,
            controller: emailCtrl,
            isReadOnly: false,
            onValidation: (value) {
              if (value == null || value.isEmpty) {
                return 'Email address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          StyledButton(
            text: "Submit",
            onPressed: submitForgotPassword,
          ),
        ],
      ),
    );
  }

  /// Update Password UI
  Widget updatePasswordView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Enter New Password"),
          const SizedBox(height: 8),
          CustomPasswordField(
            hint: "**********",
            textEditingController: newPwdCtrl,
            onValidation: validatePassword,
          ),
          const SizedBox(height: 15),
          const Text("Enter Confirm Password"),
          const SizedBox(height: 8),
          CustomPasswordField(
            hint: "**********",
            textEditingController: confirmPwdCtrl,
            onValidation: _validateConfirmPassword,
          ),
          const SizedBox(height: 15),
          StyledButton(
            text: "Submit",
            onPressed: () => updatePassword(userID),
          ),
        ],
      ),
    );
  }

  /// Forgot Password API
  Future<void> submitForgotPassword() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final payload = jsonEncode({"email": emailCtrl.text});

    final response = await _executeWithLoader(() async {
      return await DioClient().request(
        path: ApiEndPoints.forgotPasswordEndPoint,
        payload: payload,
        method: MethodType.post,
      );
    });

    if (response == null) return;

    if (response.status == "200" && response.data["status"] == 200) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showOtpDialog(context, id: response.data['data']);
      });
    } else {
      CommonUtilities.showAlertDialog(
        context,
        message: response.data['message'],
        icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
      );
    }
  }

  /// Update Password API
  Future<void> updatePassword(String userId) async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final payload = jsonEncode({
      "userId": userId,
      "password": newPwdCtrl.text,
      "confirmPassword": confirmPwdCtrl.text,
    });

    final response = await _executeWithLoader(() async {
      return await DioClient().request(
        path: ApiEndPoints.updateUserEndPoint,
        payload: payload,
        method: MethodType.patch,
      );
    });

    if (response == null) return;

    if (response.status == "200" && response.data["status"] == 200) {
      Navigator.pop(context);
    }else if (response.status == "201" && response.data["status"] == 409) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Text(response.data['message'] ?? "Something went wrong"),
            actions: [
              TextButton(
                onPressed: () =>{
                  Navigator.pop(context)
                },
                child: const Text("OK"),
              ),
            ],
          ));
    }else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(response.data['message'] ?? "Something went wrong"),
          actions: [
            TextButton(
              onPressed: () =>{
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                )
                },
              child: const Text("OK"),
            ),
          ],
        ),
      );
     /* CommonUtilities.showAlertDialog(
        context,
        message: response.data['message'],
        icon: const Icon(Icons.info_outline, color: Colors.green, size: 50),
      );*/
    }
  }

  /// OTP Dialog
  void showOtpDialog(BuildContext context, {required String id}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("OTP Verification",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter the OTP sent to your registered email",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextField(
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                counterText: "",
                hintText: "Enter OTP",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => otp = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () {
              if (otp.length == 6) {
                userID = id;
                verifyOTP(otp, id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Enter a valid 6-digit OTP")),
                );
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  /// Verify OTP API
  Future<void> verifyOTP(String otp, String id) async {
    final payload = jsonEncode({
      "id": id,
      "otp": int.parse(otp),
      "isFromForgotPassword": true
    });

    final response = await _executeWithLoader(() async {
      return await DioClient().request(
        path: ApiEndPoints.otpVerificationEndPoint,
        payload: payload,
        method: MethodType.post,
      );
    });

    if (response == null) return;

    if (response.status == "200" && response.data["status"] == 200) {
      Navigator.pop(context);
      setState(() {
        isUpdatePasswordView = true;
      });
      // close OTP dialog
    } else {
      CommonUtilities.showAlertDialog(
        context,
        message: response.data['message'],
        icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
      );
    }
  }

  @override
  void dispose() {
    if (isUpdatePasswordView) {
      newPwdCtrl.dispose();
      confirmPwdCtrl.dispose();
    } else {
      emailCtrl.dispose();
    }
    super.dispose();
  }
}
