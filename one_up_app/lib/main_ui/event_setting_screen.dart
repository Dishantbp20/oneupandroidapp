import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/model/event_details_model.dart';
import 'package:one_up_app/utils/colors.dart';

import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../utils/app_preferences.dart';
import '../utils/common_utilies.dart';
import '../widgets/custom_app_bar.dart';
import 'dashboard_screen.dart';

class EventSettingScreen extends StatefulWidget {
  final EventDetailsModel eventDetailsModel;
  const EventSettingScreen({super.key, required this.eventDetailsModel});

  @override
  State<EventSettingScreen> createState() => _EventSettingScreenState();
}

class _EventSettingScreenState extends State<EventSettingScreen> {
  bool isShowName = false;
  bool isShowDescription = false;
  bool isShowStartDate = false;
  bool isShowEndDate = false;
  bool isShowRegistrationStartDate = false;
  bool isShowRegistrationEndDate = false;

  bool isLoading = true;
  late ApiResponse apiResponse;
  late final EventDetailsModel eventDetails;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() => isLoading = true);
   getEventDetailsByIDData();
  }
  @override
  Widget build(BuildContext context) {
    return    Scaffold(
        appBar: AppBar(
          title: Text(
            "Event Settings",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Lato'),
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
          ), // 🔹 show loader while fetching
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  _buildSwitchTile("Show Name", isShowName, (val) {
                    setState(() => isShowName = val);
                  }),
                  _buildDivider(),
                  _buildSwitchTile("Show Description", isShowDescription, (val) {
                    setState(() => isShowDescription = val);
                  }),
                  _buildDivider(),
                  _buildSwitchTile("Show Start Date", isShowStartDate, (val) {
                    setState(() => isShowStartDate = val);
                  }),
                  _buildDivider(),
                  _buildSwitchTile("Show End Date", isShowEndDate, (val) {
                    setState(() => isShowEndDate = val);
                  }),
                  _buildDivider(),
                  _buildSwitchTile("Show Registration Start Date",
                      isShowRegistrationStartDate, (val) {
                        setState(() => isShowRegistrationStartDate = val);
                      }),
                  _buildDivider(),
                  _buildSwitchTile("Show Registration End Date",
                      isShowRegistrationEndDate, (val) {
                        setState(() => isShowRegistrationEndDate = val);
                      }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async{
                // Here you can save these settings to backend or local storage
                final settings = {
                  "isShowName": isShowName,
                  "isShowDescription": isShowDescription,
                  "isShowStartDate": isShowStartDate,
                  "isShowEndDate": isShowEndDate,
                  "isShowRegistrationStartDate": isShowRegistrationStartDate,
                  "isShowRegistrationEndDate": isShowRegistrationEndDate,
                };
                await updateEventSettings(settings);
               /* ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings saved successfully")),
                );*/
                debugPrint("Event Settings: $settings");
              },
              icon: const Icon(Icons.save,color: Colors.white,),
              label: const Text("Save Settings",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
    );
  }
  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }

  Widget _buildDivider() => const Divider(height: 0, thickness: 0.8);
  Future<void> getEventDetailsByIDData() async {

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getEventByIdEndPoint + widget.eventDetailsModel.id,
        method: MethodType.get,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      if (response.status == "200" || response.status == "201") {
        // final List<dynamic> jsonList = response.data["data"];

        if (response.data['status'] == 200) {
          final data = response.data['data'];
          final dynamic eventListJson = data; // extract the list
          EventDetailsModel eventList = EventDetailsModel .fromJson(eventListJson);
          setState(() {
            eventDetails = eventList;
            isShowName = eventDetails.isShowName;
            isShowDescription = eventDetails.isShowDescription;
            isShowStartDate = eventDetails.isShowStartDate;
            isShowEndDate = eventDetails.isShowEndDate;
            isShowRegistrationStartDate = eventDetails.isShowRegistrationStartDate;
            isShowRegistrationEndDate = eventDetails.isShowRegistrationEndDate;
           // your list variable
          });
        } else {
          // CommonUtilities.hideLoadingDialog(context);
        }
      } else {
        // CommonUtilities.hideLoadingDialog(context);
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded successfully!')));
    } catch (e) {
      // CommonUtilities.hideLoadingDialog(context);
      log("Error: ${e.toString()}");
      // print("Upload error: $e");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed!')));
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> updateEventSettings(dynamic formData) async {

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.addEventSettings + widget.eventDetailsModel.id,
        payload: formData,
        method: MethodType.patch,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      // if (!mounted) return;
      if (response.status == "200" || response.status == "201") {
        if (response.data["status"] == 200 || response.data["status"] == 201) {
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
                      selectedIndex: 2,
                    ),
              ),
            );
          });
          CommonUtilities.showToast(response.data['message']);
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
      CommonUtilities.hideLoadingDialog(context);
    }
  }
}
