import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:one_up_app/main_ui/dashboard_screen.dart';
import 'package:one_up_app/model/badge_detail_model.dart';
import 'package:one_up_app/model/user_details_model.dart';
import 'package:one_up_app/utils/app_preferences.dart';
import 'package:one_up_app/utils/common_utilies.dart';
import 'package:one_up_app/widgets/custom_app_bar.dart';

import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/styled_button.dart';

class EditUserScreen extends StatefulWidget {
  final String id;

  const EditUserScreen({
    super.key,
    required this.id,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final formKey = GlobalKey<FormState>();
  bool isPaid = false;

  late ApiResponse apiResponse;

  late UserDetailsModel user;
  List<BadgeDetailsModel> badgeDetails = [];
  List<BadgeDetailsModel> selectBadgeDetails = [];
  final playerIdCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppPreferences.init();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => isLoading = true);

    try {
      // 1️⃣ Get user details first (we need user.id)
      await getUserListByIDData(widget.id);

      // 2️⃣ Get all badges
      await setBadgeDropdownList();


    } catch (e) {
      log("❌ _loadDropdownData() error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Player Profile",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,fontFamily: 'Lato',
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
      body: isLoading
          ? Center(
        child: Lottie.asset(
          'assets/animations/loader.json',
          width: 120,
          height: 120,
          repeat: true,
        ), // 🔹 show loader while fetching
      )
          :  Stack(
        children: [
          // Form content
          Container(
            margin: EdgeInsets.only(top: 50),
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Only Admin can change the user details.',
                        style: TextStyle(
                            fontSize: 16,fontFamily: 'Lato', fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Please fill the details and update details.',
                        style: TextStyle(
                            fontSize: 14,fontFamily: 'Lato',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.normal,
                            color: AppColors.lightGrey.withAlpha(80)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.01),
                      // Player ID field
                      CustomTextField(
                          controller: playerIdCtrl,
                          hint: "Enter your player id",
                          icon: Icons.person,
                          isReadOnly: true,
                          textInputType: TextInputType.text),
                      SizedBox(height: height * 0.01),
                      CustomTextField(
                          controller: nameCtrl,
                          hint: "Enter your full name",
                          isReadOnly: false,
                          icon: Icons.person,
                          textInputType: TextInputType.text),
                      SizedBox(height: height * 0.01),
                      Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(12),
                          child: TextFormField(
                            controller: dobCtrl,
                            //editing controller of this TextField
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: "Enter your date of birth",
                              hintStyle: TextStyle(
                                  color: AppColors.lightGrey.withAlpha(80)),
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: AppColors.lightGrey),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.edit_calendar,
                                    color: AppColors.lightGrey.withAlpha(50)),
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2100));

                                  if (pickedDate != null) {
                                    //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate =
                                        DateFormat('dd-MM-yyyy')
                                            .format(pickedDate);
                                    //formatted date output using intl package =>  2021-03-16
                                    setState(() {
                                      dobCtrl.text =
                                          formattedDate; //set output date to TextField value.
                                    });
                                  } else {
                                    /*String formattedDate =
                                    DateFormat('dd/MM/yyyy')
                                        .format(DateTime.now());
                                    //formatted date output using intl package =>  2021-03-16
                                    setState(() {
                                      dateInput.text =
                                          formattedDate; //set output date to TextField value.
                                    });*/
                                  }
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              //icon of text field
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
                            //set it true, so that user will not able to edit text
                            onTap: () async {},
                          )),
                      SizedBox(height: height * 0.01),
                      /*Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            boxShadow: List.filled(10, BoxShadow()),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white
                        ),
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.image,color: AppColors.lightGrey),
                            Column(
                              children: [
                                Text(
                                  fileName,
                                  style: TextStyle(
                                      color: Colors.black
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: pickFile,
                                  icon: Icon(Icons.file_upload),
                                  label: Text('Choose ID Card (JPG/PNG)'),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: width * 0.1,
                            )

                          ],)
                        ,
                      ),
                      SizedBox(height: height * 0.01),*/
                      /* Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                        child: TextFormField(
                          controller: roleCtrl,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Create your user name",
                            hintStyle:
                            TextStyle(color: AppColors.lightGrey.withAlpha(80)),
                            prefixIcon: Icon(Icons.account_box),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.info,
                                color: AppColors.lightGrey.withAlpha(50),
                              ),
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
                      SizedBox(height: height * 0.01),*/

                      CustomTextField(
                          controller: emailCtrl,
                          hint: "Enter your email address",
                          icon: Icons.mail,
                          isReadOnly: false,
                          textInputType: TextInputType.emailAddress),
                      SizedBox(height: height * 0.01),
                      CustomTextField(
                          controller: addressCtrl,
                          hint: "Enter your address",
                          isReadOnly: false,
                          icon: Icons.location_city,
                          textInputType: TextInputType.text),
                      SizedBox(height: height * 0.01),
                      _buildBadgesTypeDropdown(),
                      SizedBox(height: height * 0.01),
                      /*CustomTextField(
                      hint: "Enter your phone number",
                      icon: Icons.call,
                      textInputType: TextInputType.phone),
                  SizedBox(height: height * 0.01),*/
                      /*CustomPasswordField(
                        hint: "Create a new password",
                        textEditingController: passwordCtrl,
                      ),
                      SizedBox(height: height * 0.01),
                      CustomPasswordField(
                        hint: "Enter a confirm password",
                        textEditingController: confirmPasswordCtrl,
                      ),*/
                      /* SizedBox(height: height * 0.01),
                      Row(
                        children: [
                          Checkbox(
                            value: isPaid,
                            onChanged: (val) {
                              setState(() {
                                isPaid = val ?? false;
                              });
                            },
                          ),
                          const Text('Is Paid'),
                        ],
                      ),*/

                      SizedBox(height: 25),

                      StyledButton(
                        text: "Update Player Details",
                        onPressed: () {
                          // showOtpDialog(context,id: '123456');
                          updateUserDetails();
                        },
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
  Widget _buildBadgesTypeDropdown() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: MultiSelectDialogField<BadgeDetailsModel>(
          items: badgeDetails
              .map((badge) =>
              MultiSelectItem<BadgeDetailsModel>(badge, badge.bedgeName))
              .toList(),
          initialValue: selectBadgeDetails,
          title: const Text("Assign Badges"),
          buttonText: const Text("Choose Badges"),
          searchable: true,
          onConfirm: (values) async {
            await _handleBadgeSelectionChange(values);
          },
        ),
      ),
    );
  }

  Future<void> _handleBadgeSelectionChange(List<BadgeDetailsModel> newSelection) async {
    final previousSelection = List<BadgeDetailsModel>.from(selectBadgeDetails);

    setState(() {
      selectBadgeDetails = newSelection;
    });

    // 🔍 Find added badges
    final addedBadges = newSelection
        .where((b) => !previousSelection.contains(b))
        .toList();

    // 🔍 Find removed badges
    final removedBadges = previousSelection
        .where((b) => !newSelection.contains(b))
        .toList();

    log("✅ Added badges: ${addedBadges.map((b) => b.bedgeName)}");
    log("❌ Removed badges: ${removedBadges.map((b) => b.bedgeName)}");

    // 1️⃣ Assign new badges
    for (final badge in addedBadges) {
      await _assignBadgeToUser();
    }

    // 2️⃣ Remove unselected badges
    for (final badge in removedBadges) {
      await _removeBadgeFromUser(badge);
    }
  }


  Future<void> _assignBadgeToUser() async{
    List<String> selectBadgeDetailsIds = selectBadgeDetails.map((eventType) => eventType.id).toList();
    var formData = jsonEncode({
      "userId": user.id,
      "bedges": selectBadgeDetailsIds
    });
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.assignBadgeToUserEndPoint,
        payload: formData,
        method: MethodType.post,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      if (response.status == "200" || response.status == "201") {


        if (response.data["status"] == 200 ||response.data["status"] == 201) {

        }
      }
    }catch(e){
      log("Error: ${e.toString()}");
    }
  }
  Future<void> _removeBadgeFromUser(BadgeDetailsModel badge) async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.removeBadgeToUserEndPoint,
        method: MethodType.patch,
        payload: {
          "userId": user.id,
          "bedgeId": badge.id,
        },
      );

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          log("🗑️ Badge '${badge.bedgeName}' removed from user.");
        }
      }
    } catch (e) {
      log("❌ removeBadgeFromUser() error: $e");
    }
  }
  Future<void> updateUserDetails() async {
    CommonUtilities.showLoadingDialog(context);
    FormData formData = FormData.fromMap({
      "name": nameCtrl.text,
      "dob": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(dobCtrl.text)),
      "address": addressCtrl.text,
      "email": emailCtrl.text,
      "userId": user.id,
      // "isPaid": isPaid.toString(),
    });
    log(" - name: ${nameCtrl.text}");
    log(" - dob: ${dobCtrl.text}");
    log(" - address: ${addressCtrl.text}");
    log(" - email: ${emailCtrl.text}");
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.updateUserEndPoint,
        payload: formData,
        method: MethodType.patch,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      // if (!mounted) return;
      if (response.status == "200" || response.status == "201") {


        if (response.data["status"] == 200 ||response.data["status"] == 201) {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: Icon(Icons.check_circle, color: Colors.green, size: 50),
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DashboardScreen(
                      isAdmin: AppPreferences.getIsAdmin(),
                    ),
              ),
            );
          });
        }
        // CommonUtilities.showToast("Successfully sign up");
      } else {
        CommonUtilities.showAlertDialog(context,
            message: response.data['message'],
            icon: Icon(
              Icons.warning_amber,
              color: Colors.red,
              size: 50,
            ));
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded successfully!')));
    } catch (e) {
      log("Error: ${e.toString()}");
      // print("Upload error: $e");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed!')));
    } finally {
    }
  }

  Future<void> getUserListByIDData(String id) async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getUserByIdEndPoint + id,
        method: MethodType.get,
      );

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          final userModel = UserDetailsModel.fromJson(data);

          user = userModel;
          setData();
        }
      }
    } catch (e) {
      log("❌ getUserListByIDData() error: $e");
    }
  }


  Future<void> setBadgeDropdownList() async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getBadgeListEndPoint,
        method: MethodType.get,
      );

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final List<dynamic> bedgeData = response.data['data']['BedgeDetails'];
          badgeDetails =
              bedgeData.map((json) => BadgeDetailsModel.fromJson(json)).toList();
          await setSelectedBadgeList();
        }
      }
    } catch (e) {
      log("❌ setBadgeDropdownList() error: $e");
    }
  }

  Future<void> setSelectedBadgeList() async {
    if (user.id.isEmpty) return; // safeguard

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getBadgesOfUsersEndPoint + user.id,
        method: MethodType.get,
      );

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final List<dynamic> badgeData = response.data['data'];
          selectBadgeDetails = badgeData
              .map((b) => BadgeDetailsModel(
            id: b['bedgeId'],
            bedgeName: b['bedgeName'],
              image: b['image'],
            isActive: b['isActive']
          ))
              .toList();
        }
      }
    } catch (e) {
      log("❌ setSelectedBadgeList() error: $e");
    }
  }


  void setData() {
    playerIdCtrl.text = user.playerId;
    nameCtrl.text = user.name;
    // roleCtrl.text = user.role;
    addressCtrl.text = user.address;
    emailCtrl.text = user.email;
    dobCtrl.text =
        DateFormat("dd-MM-yyyy").format(DateTime.parse((user.dob).toString()));
  }
}
