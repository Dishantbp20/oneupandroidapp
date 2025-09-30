import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:one_up_app/model/game_details_model.dart';
import 'package:one_up_app/utils/app_preferences.dart';

import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/styled_button.dart';
import 'dashboard_screen.dart';

class CreateGameScreen extends StatefulWidget {
  final bool isEdit;
  final String id;
  const CreateGameScreen({super.key, required this.isEdit, required this.id});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final formKey = GlobalKey<FormState>();
  File? selectedFile;
  bool isStatus = false;
  late ApiResponse apiResponse;
  late GameDetailsModel gameDetails;
  String fileName = "Please select image from library.";
  final gameNameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getGameDetailsByIDData(widget.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create new game",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Lato',
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        flexibleSpace: CustomAppBar(),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 25),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '"Think it. Design it. Build it. Play it. Improve it. Share it." 🎮',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        fontStyle: FontStyle.italic,
                        color: AppColors.lightGrey.withAlpha(80),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.01),

                    /// Game Name
                    TextFormField(
                      controller: gameNameCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter a Game name",
                        prefixIcon: const Icon(Icons.videogame_asset_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Game name is required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.01),

                    /// Description
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: TextFormField(
                        controller: descriptionCtrl,
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Game Description...",
                          hintStyle: TextStyle(
                              color: AppColors.lightGrey.withAlpha(80)),
                          prefixIcon: const Icon(Icons.description),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Description is required";
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: height * 0.01),

                    /// Status
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(Icons.account_tree_sharp,
                                color: AppColors.lightGrey),
                            const SizedBox(width: 15),
                            const Text('Status',
                                style: TextStyle(color: Colors.grey)),
                            const Spacer(),
                            Checkbox(
                              value: isStatus,
                              onChanged: (val) {
                                setState(() {
                                  isStatus = val ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.01),

                    /// Image Upload
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
                                : Icon(Icons.image, color: AppColors.lightGrey, size: 60),
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
                                      color:
                                      AppColors.lightGrey.withAlpha(80)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Choose Image (JPG/PNG)',
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

                    const SizedBox(height: 25),

                    StyledButton(
                      text: "Create a Game",
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (formKey.currentState!.validate()) {
                          if (selectedFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select an image"),
                              ),
                            );
                            return;
                          }
                          if (widget.isEdit) {
                            updateGameDetails();
                          } else {
                            submitForm();
                          }

                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        selectedFile = file;
        fileName = result.names.single ?? file.path.split('/').last;
      });
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    log("On click create game...");
    CommonUtilities.showLoadingDialog(context);

    FormData formData = FormData.fromMap({
      "logo": await MultipartFile.fromFile(
        selectedFile!.path,
        filename: selectedFile!.path.split('/').last,
        contentType: MediaType("image", selectedFile!.path.split('.').last),
      ),
      "name": gameNameCtrl.text.trim(),
      "description": descriptionCtrl.text.trim(),
      "status": isStatus.toString(),
    });

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.createGameEndPoint,
        payload: formData,
        method: MethodType.post,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data["status"] == 200 ||
            response.data["status"] == 201) {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: const Icon(Icons.check_circle,
                color: Colors.green, size: 50),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  isAdmin: AppPreferences.getIsAdmin(),
                  selectedIndex: 3, // 👈 Game Listing
                ),
              ),
            );
          });
          CommonUtilities.showToast(response.data['message']);
        } else {
          CommonUtilities.showToast(response.data['message']);
        }
      } else {
        CommonUtilities.showToast(response.data['message']);
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    } finally {
      CommonUtilities.hideLoadingDialog(context);
    }
  }
  Future<void> updateGameDetails() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    log("On click create game...");
    CommonUtilities.showLoadingDialog(context);

    FormData formData = FormData.fromMap({
      "logo": await MultipartFile.fromFile(
        selectedFile!.path,
        filename: selectedFile!.path.split('/').last,
        contentType: MediaType("image", selectedFile!.path.split('.').last),
      ),
      "name": gameNameCtrl.text.trim(),
      "description": descriptionCtrl.text.trim(),
      "status": isStatus.toString(),
    });

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.updateGameEndPoint + gameDetails.id,
        payload: formData,
        method: MethodType.post,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data["status"] == 200 ||
            response.data["status"] == 201) {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: const Icon(Icons.check_circle,
                color: Colors.green, size: 50),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  isAdmin: AppPreferences.getIsAdmin(),
                  selectedIndex: 3, // 👈 Game Listing
                ),
              ),
            );
          });
          CommonUtilities.showToast(response.data['message']);
        } else {
          CommonUtilities.showToast(response.data['message']);
        }
      } else {
        CommonUtilities.showToast(response.data['message']);
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    } finally {
      CommonUtilities.hideLoadingDialog(context);
    }
  }

  Future<void> getGameDetailsByIDData(String id) async {
    CommonUtilities.showLoadingDialog(context);
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getGameByIdEndPoint + id,
        method: MethodType.get,
      );

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          GameDetailsModel details = GameDetailsModel.fromJson(data);
          CommonUtilities.hideLoadingDialog(context);
          setState(() {
            gameDetails = details;
            setData();
          });
        } else {
          CommonUtilities.hideLoadingDialog(context);
        }
      } else {
        CommonUtilities.hideLoadingDialog(context);
      }
    } catch (e) {
      CommonUtilities.hideLoadingDialog(context);
      log("Error: ${e.toString()}");
    }
  }

  void setData() {
    gameNameCtrl.text = gameDetails.name;
    descriptionCtrl.text = gameDetails.description;
    isStatus = gameDetails.status;
  }
}
