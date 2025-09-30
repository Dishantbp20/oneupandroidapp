import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:one_up_app/api_service/api_response.dart';
import 'package:one_up_app/model/event_type_details_model.dart';

import '../api_service/api_end_points.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/app_preferences.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/styled_button.dart';
import 'dashboard_screen.dart';

class CreateEventTypeScreen extends StatefulWidget {
  final bool isEdit;
  final String id;
  const CreateEventTypeScreen({super.key, required this.isEdit, required this.id});

  @override
  State<CreateEventTypeScreen> createState() => _CreateEventTypeScreenState();
}

class _CreateEventTypeScreenState extends State<CreateEventTypeScreen> {
  final formKey = GlobalKey<FormState>();
  final eventTypeNameCtrl = TextEditingController();
  late ApiResponse apiResponse;
  late EventTypeDetailsModel eventTypeDetails;

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getEventListByIDData(widget.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create new event type",
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
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.isEdit ? 'Edit event type' : 'Create event type',
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

                    /// Event type name
                    TextFormField(
                      controller: eventTypeNameCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter an Event Type name",
                        prefixIcon: const Icon(Icons.event),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Event type name is required";
                        }
                        if (value.trim().length < 3) {
                          return "Event type name must be at least 3 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    StyledButton(
                      text: "Submit",
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (formKey.currentState!.validate()) {
                          if (widget.isEdit) {
                            updateEventType();
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

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    log("On click create event type...");
    CommonUtilities.showLoadingDialog(context);

    var formData = jsonEncode({
      "eventTypeName": eventTypeNameCtrl.text.trim(),
    });

    log("📝 Form Data: $formData");

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.createEventTypeEndPoint,
        payload: formData,
        method: MethodType.post,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });

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
                  selectedIndex: 1, // Event type listing tab
                ),
              ),
            );
          });
          CommonUtilities.showToast(response.data['message']);
        } else {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
          );
        }
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    } finally {
      CommonUtilities.hideLoadingDialog(context);
    }
  }

  Future<void> updateEventType() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    log("On click update event type...");
    CommonUtilities.showLoadingDialog(context);

    var formData = jsonEncode({
      "eventTypeName": eventTypeNameCtrl.text.trim(),
    });

    log("📝 Form Data: $formData");

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.updateEventTypeEndPoint + eventTypeDetails.id,
        payload: formData,
        method: MethodType.patch,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });

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
                  selectedIndex: 1,
                ),
              ),
            );
          });
          CommonUtilities.showToast(response.data['message']);
        } else {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
          );
        }
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    } finally {
      CommonUtilities.hideLoadingDialog(context);
    }
  }

  Future<void> getEventListByIDData(String id) async {
    CommonUtilities.showLoadingDialog(context);
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getEventTypeByIdEndPoint + id,
        method: MethodType.get,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];
          EventTypeDetailsModel eventList = EventTypeDetailsModel.fromJson(data);
          CommonUtilities.hideLoadingDialog(context);
          setState(() {
            eventTypeDetails = eventList;
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
    eventTypeNameCtrl.text = eventTypeDetails.eventTypeName;
  }
}
