import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../model/SubscriptionOption.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';
import '../utils/image_path.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/styled_button.dart';
import '../widgets/top_curve_clipper.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  File? selectedFile;
  final formKey = GlobalKey<FormState>();
  bool isPaid = false;
  late ApiResponse apiResponse;
  bool isLoading = false;

  String fileName = "Please select image from library.";
  String data = "";
  String otp = "";
  final DioClient _apiClient = DioClient();

  String responseText = "";
  int _selectedIndex = -1;
  // Form fields
  final nameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{6,20}$';

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
    if (value != passwordCtrl.text) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: AppColors.getGradientColor(),
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage(appLogo),
                    width: 140,
                    height: 75,
                  ),
                  Text(
                    "Sports App",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),

          /*Container(
            alignment: Alignment.topCenter,
              child: ),
          Column(
            children: [

            ],
          ),*/
          // Form content
          Container(
            margin: EdgeInsets.only(top: 180),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Text(
                      'Create an Account',
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Please fill the details and create account',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lato',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.normal,
                          color: AppColors.lightGrey.withAlpha(80)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.015),

                    // Name field
                    CustomTextField(
                        controller: nameCtrl,
                        hint: "Enter your full name",
                        icon: Icons.person,
                        isReadOnly: false,
                        onValidation: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                        textInputType: TextInputType.text),
                    SizedBox(height: height * 0.015),

                    // Date of Birth field
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: TextFormField(
                        controller: dobCtrl,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Enter your date of birth",
                          hintStyle: TextStyle(
                              color: AppColors.lightGrey.withAlpha(80),
                              fontSize: 14),
                          prefixIcon: Icon(Icons.calendar_today,
                              color: AppColors.lightGrey),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.edit_calendar,
                                color: AppColors.lightGrey.withAlpha(150)),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime(2100));
                              if (pickedDate != null) {
                                String formattedDate =
                                    DateFormat('dd-MM-yyyy').format(pickedDate);
                                setState(() {
                                  dobCtrl.text = formattedDate;
                                });
                              }
                            },
                          ),
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
                        readOnly: true,
                        onTap: () async {},
                      ),
                    ),
                    SizedBox(height: height * 0.015),

                    // Username
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: TextFormField(
                        style: TextStyle(fontSize: 14),
        controller: usernameCtrl,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Create your user name",
                          hintStyle: TextStyle(
                              color: AppColors.lightGrey.withAlpha(80),
                              fontSize: 14),
                          prefixIcon: Icon(Icons.account_box),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.info,
                                color: AppColors.lightGrey.withAlpha(150)),
                            onPressed: () {},
                          ),
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
                    SizedBox(height: height * 0.015),

                    // Email
                    CustomTextField(
                        controller: emailCtrl,
                        hint: "Enter your email address",
                        icon: Icons.mail,
                        isReadOnly: false,
                        onValidation: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email address is required';
                          }
                          return null;
                        },
                        textInputType: TextInputType.emailAddress),
                    SizedBox(height: height * 0.015),

                    // Address
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: TextFormField(
                        style: TextStyle(fontSize: 14),
        controller: addressCtrl,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your address",
                          hintStyle: TextStyle(
                              color: AppColors.lightGrey.withAlpha(80),
              fontSize: 14),
                          prefixIcon: Icon(Icons.location_city),
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
                    SizedBox(height: height * 0.015),

                    // Password fields
                    CustomPasswordField(
                      hint: "Create a new password",
                      textEditingController: passwordCtrl,
                      onValidation: validatePassword,
                    ),
                    SizedBox(height: height * 0.015),

                    CustomPasswordField(
                      hint: "Enter a confirm password",
                      textEditingController: confirmPasswordCtrl,
                      onValidation: _validateConfirmPassword,
                    ),
                    SizedBox(height: height * 0.015),

                    // ID Card uploader
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            selectedFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      selectedFile!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.image,
                                    color: AppColors.lightGrey, size: 60),
                            Row(
                              children: [
                                // const Icon(Icons.image, color: Colors.grey),

                                Expanded(
                                  child: Text(
                                    fileName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: pickFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: AppColors.lightGrey.withAlpha(80),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.file_upload,
                                      color: AppColors.lightGrey.withAlpha(80)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Choose your ID Card (JPG/PNG)',
                                    style: TextStyle(
                                        color:
                                            AppColors.lightGrey.withAlpha(80)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.015),

                    // Paid account row

                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child:Container(
                          padding: EdgeInsets.all(15),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.account_balance_wallet,color: AppColors.primaryBlue,),
                              Expanded(
                                child: Text(
                                  'Subscription',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                      fontSize: 15
                                  ),
                                ),),
                              ElevatedButton(
                                onPressed: () {
                                  feesPaymentView();
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Padding(padding: EdgeInsets.symmetric(horizontal: 5),child: Text(
                                  "Click here!",
                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                ),) ,
                              ),
                            ],
                          ) ), /*Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet,
                                color: AppColors.lightGrey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Paid account',
                                    style:
                                        TextStyle(color: AppColors.lightGrey),
                                  ),
                                  Text(
                                    '(Note: If you want paid account check the box.)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.lightGrey.withAlpha(80),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isPaid,
                              onChanged: (val) {
                                setState(() {
                                  isPaid = val ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),*/
                    ),
                    const SizedBox(height: 25),

                    // Sign up button
                    StyledButton(
                      text: "Sign up",
                      onPressed: () {
                        submitForm();
                      },
                    ),
                    const SizedBox(height: 10),

                    // Already have an account row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign in",
                            style: TextStyle(fontSize: 14, fontFamily: 'Lato'),
                          ),
                        ),
                        if (isLoading)
                          Container(
                            color: Colors.black26,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          /* Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.all(10),
              child: Text(
                'v$version',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,fontFamily: 'Lato',
                ),@
              ))*/
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }
  SubscriptionOption? selectedSubscription;
  void feesPaymentView(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isPaidSubscription = selectedSubscription?.isPaid ?? false;

        return StatefulBuilder(
          builder: (context, setState)
        {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Choose Subscription",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: SubscriptionOption.subscriptionOptions.length,
                itemBuilder: (context, index) {
                  final option = SubscriptionOption.subscriptionOptions[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      leading: Radio<int>(
                        value: index,
                        groupValue: _selectedIndex,
                        onChanged: (value) {
                          setState(() {
                            _selectedIndex = value!;
                          });
                        },
                      ),
                      title: Text(
                        option.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(option.description),
                      trailing: option.isPaid
                          ? Text(
                        "₹${option.price}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            /// Actions
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              if (!isPaidSubscription) // Only show payment if Free subscription
                StyledButton(
                  text: "Proceed Payment",
                  onPressed: () {
                    if(_selectedIndex == 0) {
                      isPaid = true;
                    }else{
                      isPaid = false;
                    }
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }
/*
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (!RegExp(passwordPattern).hasMatch(value)) {
      return '6–20 chars, include upper, lower, number & special char';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return "Confirm password is required";
    if (value != passwordCtrl.text) return "Passwords do not match";
    return null;
  }
*/

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        openAppSettings();
      }
    }
  }

  Future<void> pickFile() async {
    await requestPermission();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        selectedFile = file;
        fileName = result.names.single ?? "selected_image.png";
      });
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate() || selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and pick an image')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final formData = FormData.fromMap({
        "idCard": await MultipartFile.fromFile(
          selectedFile!.path,
          filename: selectedFile!.path.split('/').last,
          contentType: MediaType("image", selectedFile!.path.split('.').last),
        ),
        "name": nameCtrl.text,
        "username": usernameCtrl.text,
        "dob": DateFormat("yyyy-MM-dd")
            .format(DateFormat("dd-MM-yyyy").parse(dobCtrl.text)),
        "address": addressCtrl.text,
        "email": emailCtrl.text,
        "password": passwordCtrl.text,
        "confirmPassword": confirmPasswordCtrl.text,
        "isPaid": isPaid.toString(),
      });

      final response = await _apiClient.request(
        path: ApiEndPoints.registrationEndPoint,
        payload: formData,
        method: MethodType.post,
      );

      if (response.status == "200" || response.status == "201") {
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
    } catch (e) {
      log("Error: $e");
      CommonUtilities.showAlertDialog(
        context,
        message: "Something went wrong. Please try again.",
        icon: const Icon(Icons.error, color: Colors.red, size: 50),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

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

  Future<void> verifyOTP(String otp, String id) async {
    setState(() => isLoading = true);

    try {
      final payload = jsonEncode({"id": id, "otp": int.parse(otp)});
      final response = await _apiClient.request(
        path: ApiEndPoints.otpVerificationEndPoint,
        payload: payload,
        method: MethodType.post,
      );

      if (response.status == "200" && response.data["status"] == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        CommonUtilities.showAlertDialog(
          context,
          message: response.data['message'],
          icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
        );
      }
    } catch (e) {
      log("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
}

class SignUpTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 100); // start below top
    path.quadraticBezierTo(size.width / 2, 0, size.width, 100);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
