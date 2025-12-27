import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/model/ad_details.dart';
import 'package:file_picker/file_picker.dart';
import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/app_preferences.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/styled_button.dart';
import 'dashboard_screen.dart';

class CreateAdsScreen extends StatefulWidget {
  final bool isEdit;
  final String id;

  const CreateAdsScreen({super.key, required this.isEdit, required this.id});

  @override
  State<CreateAdsScreen> createState() => _CreateAdsScreenState();
}

class _CreateAdsScreenState extends State<CreateAdsScreen> {
  final formKey = GlobalKey<FormState>();
  late ApiResponse apiResponse;
  late AdDetailsModel adsDetails;

  final adNameCtrl = TextEditingController();
  final adDescriptionCtrl = TextEditingController();

  bool isActive = false;
  bool isLoading = true;
  File? selectedFile;
  String fileName = "Please select image from library.";

  @override
  void initState() {
    super.initState();
    adsDetails = AdDetailsModel(id: '', adName: '', adDescription: '', image: '', isActive: false);
    if (widget.isEdit) {
      // ✅ Show loader while fetching details
      setState(() => isLoading = true);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await getAdDetailsByIDData(widget.id);
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? "Edit ads" : "Create new ad",
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontFamily: 'Lato'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: CustomAppBar(),
      ),
      body: isLoading
          ? Center(
        child: Lottie.asset(
          'assets/animations/loader.json',
          width: 120,
          height: 120,
          repeat: true,
        ),
      )
          : _buildFormContent(height),
    );
  }

  Widget _buildFormContent(double height) {
    return Stack(
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
                    '"Where Great Moments Begin."',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Lato',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.normal,
                      color: AppColors.lightGrey.withAlpha(80),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.01),

                  // Ad name
                  _buildEventTextFieldLabel("Ad name"),
                  CustomTextField(
                    controller: adNameCtrl,
                    hint: "Enter Ad name",
                    isReadOnly: false,
                    icon: Icons.videogame_asset_outlined,
                    textInputType: TextInputType.text,
                  ),

                  SizedBox(height: height * 0.01),

                  _buildEventTextFieldLabel("Ad Description"),
                  CustomTextField(
                    controller: adDescriptionCtrl,
                    hint: "Enter Ad Description",
                    isReadOnly: false,
                    icon: Icons.videogame_asset_outlined,
                    textInputType: TextInputType.text,
                  ),

                  SizedBox(height: height * 0.02),

                  /// ✅ Checkbox for Active/Inactive
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        onChanged: (value) {
                          setState(() => isActive = value ?? false);
                        },
                      ),
                      const Text(
                        "Is Active?",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.01),

                  /// Image Upload
                  _buildEventTextFieldLabel("Upload Ad image"),
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
                              : /*widget.isEdit? Icon(Icons.image,
                              color: AppColors.lightGrey, size: 60):*/
                          Image.network(adsDetails.image,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return Icon(Icons.image,
                                    color: AppColors.lightGrey, size: 60); // Display an error icon if the image fails to load
                              }
                          ),
                          Row(
                            children: [
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
                                  'Choose Image (JPG/PNG)',
                                  style: TextStyle(
                                      color: AppColors.lightGrey.withAlpha(80)),
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
                    text: "Submit",
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      updateAdDetails();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTextFieldLabel(String labelText) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        labelText,
        style:
        const TextStyle(color: Colors.black, fontFamily: 'Lato', fontSize: 15),
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

  Future<void> updateAdDetails() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    CommonUtilities.showLoadingDialog(context);

    final Map<String, dynamic> data = {
      "adName": adNameCtrl.text,
      "adDescription": adDescriptionCtrl.text,
      "isActive": isActive,
      "image": await MultipartFile.fromFile(
        selectedFile!.path,
        filename: selectedFile!.path.split('/').last,
        contentType: MediaType("image", selectedFile!.path.split('.').last),
      ),
    };

    if (widget.isEdit) {
      data["id"] = adsDetails.id;
    }

    FormData formData = FormData.fromMap(data);

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.updateAd,
        payload: formData,
        method: MethodType.post,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() => apiResponse = response);

      if (response.status == "200" || response.status == "201") {
        if (response.data["status"] == 200 || response.data["status"] == 201) {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  isAdmin: AppPreferences.getIsAdmin(),
                  selectedIndex: 5,
                ),
              ),
            );
          });

          CommonUtilities.showToast(response.data['message']);
        }
      } else {
        CommonUtilities.showAlertDialog(
          context,
          message: response.data['message'],
          icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
        );
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    } finally {
      CommonUtilities.hideLoadingDialog(context);
    }
  }

  Future<void> getAdDetailsByIDData(String id) async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getAdById + id,
        method: MethodType.get,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          final adList = AdDetailsModel.fromJson(data);

          setState(() {
            adsDetails = adList;
            adNameCtrl.text = adList.adName;
            adDescriptionCtrl.text = adList.adDescription;
            isActive = adList.isActive; // ✅ set checkbox state
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      log("❌ Error in getAdDetailsByIDData: ${e.toString()}");
      setState(() => isLoading = false);
    }
  }
}
