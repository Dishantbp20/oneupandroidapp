import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:one_up_app/model/event_details_model.dart';
import 'package:one_up_app/model/event_type_details_model.dart';
import 'package:one_up_app/model/game_details_model.dart';

import '../api_service/api_end_points.dart';
import '../api_service/api_response.dart';
import '../api_service/dio_client.dart';
import '../api_service/web_client.dart';
import '../model/SubscriptionOption.dart';
import '../utils/app_preferences.dart';
import '../utils/colors.dart';
import '../utils/common_utilies.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/styled_button.dart';
import 'dashboard_screen.dart';

class CreateEventScreen extends StatefulWidget {
  final bool isEdit;
  final String id;
  const CreateEventScreen({super.key, required this.isEdit, required this.id});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  List<GameDetailsModel> selectedGames = [];
  List<EventTypeDetailsModel> selectedEventType = [];
  final formKey = GlobalKey<FormState>();
  late ApiResponse apiResponse;
  late EventDetailsModel eventDetails;

  final eventNameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final eventStartDateCtrl = TextEditingController();
  final eventEndDateCtrl = TextEditingController();
  final registrationStartDateCtrl = TextEditingController();
  final registrationEndDateCtrl = TextEditingController();

  List<GameDetailsModel> games = [];
  List<EventTypeDetailsModel> eventTypes = [];

  bool isLoading = true; // 🔹 show loader until dropdown data ready

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => isLoading = true);

    await setGamesDropdownList(); // fetch games + event types
    if (widget.isEdit) {
      await getEventDetailsByIDData(widget.id); // fetch event details if editing
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? "Edit event" : "Create new event",
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
          : Stack(
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
                      '"Kick Off Your Next Big Event."',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lato',
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.normal,
                          color: AppColors.lightGrey.withAlpha(80)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: height * 0.01),
                    // Event name
                    _buildEventTextFieldLabel("Event name"),
                    CustomTextField(
                      controller: eventNameCtrl,
                      hint: "Enter a Event name",
                      isReadOnly: false,
                      icon: Icons.videogame_asset_outlined,
                      textInputType: TextInputType.text,
                    ),
                    SizedBox(height: height * 0.01),

                    // Description
                    _buildEventTextFieldLabel("Description"),
                    _buildDescriptionField(),
                    SizedBox(height: height * 0.01),

                    // Start Date
                    _buildEventTextFieldLabel("Event Start Date"),
                    _buildStartDateField("Enter Event Start date",eventStartDateCtrl),
                    SizedBox(height: height * 0.01),

                    // End Date
                    _buildEventTextFieldLabel("Event End Date"),
                    _buildEndDateField("Enter Event End date", eventEndDateCtrl, eventStartDateCtrl),
                    SizedBox(height: height * 0.01),

                    _buildEventTextFieldLabel("Event Registration Start Date"),
                    _buildStartDateField("Enter Registration Start date",registrationStartDateCtrl),
                    SizedBox(height: height * 0.01),

                    // End Date
                    _buildEventTextFieldLabel("Event Registration End Date"),
                    _buildEndDateField("Enter Registration End date", registrationEndDateCtrl, registrationStartDateCtrl),
                    SizedBox(height: height * 0.01),

                    // Event Types dropdown
                    _buildEventTextFieldLabel("Event Type"),
                    _buildEventTypeDropdown(),
                    SizedBox(height: height * 0.01),

                    // Games dropdown
                    _buildEventTextFieldLabel("Games"),
                    _buildGamesDropdown(),

                    const SizedBox(height: 25),

                    StyledButton(
                      text: "Submit",
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (widget.isEdit) {
                          updateEventDetails();
                        } else {
                          createEventDetails();
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

  /// ----------------------
  /// Form Widgets
  /// ----------------------

  Widget _buildDescriptionField() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
        controller: descriptionCtrl,
        minLines: 3,
        maxLines: 5,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Description is required";
          }
          return null;
        },
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: "Event Description...",
          hintStyle: TextStyle(color: AppColors.lightGrey.withAlpha(80)),
          prefixIcon: const Icon(Icons.description),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStartDateField(String hintText, TextEditingController controller) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText:hintText,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                setState(() {
                  controller.text = formattedDate;
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
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildEndDateField(String hintText, TextEditingController controller, TextEditingController startController) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText:hintText ,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                if (startController.text.isNotEmpty) {
                  DateTime startDate = DateFormat('dd-MM-yyyy').parse(startController.text);
                  if (pickedDate.isBefore(startDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("End date must be after start date"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                setState(() {
                  controller.text = formattedDate;
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
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildEventTextFieldLabel(String labelText){
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        labelText,
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Lato',
          fontSize: 15
        ),
      ),
    );
  }


  Widget _buildEventTypeDropdown() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: MultiSelectDialogField(
          items: eventTypes
              .map((eventType) => MultiSelectItem<EventTypeDetailsModel>(eventType, eventType.eventTypeName))
              .toList(),
          initialValue: selectedEventType,
          title: const Text("Select Event Types "),
          buttonText: const Text("Choose Event Types"),

          searchable: true,
          validator: (values) {
            if (values == null || values.isEmpty) {
              return "Please select at least one event type";
            }
            return null;
          },
          onConfirm: (values) {
            setState(() {
              selectedEventType = values;
            });
          },
        ),
      ),
    );
  }

  Widget _buildGamesDropdown() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: MultiSelectDialogField(
          items: games.map((game) => MultiSelectItem<GameDetailsModel>(game, game.name)).toList(),
          initialValue: selectedGames,
          title: const Text("Select Games"),
          buttonText: const Text("Choose Games"),
          searchable: true,
          validator: (values) {
            if (values == null || values.isEmpty) {
              return "Please select at least one game";
            }
            return null;
          },
          onConfirm: (values) {
            setState(() {
              selectedGames = values;
            });
          },
        ),
      ),
    );
  }
  Future<void> getEventDetailsByIDData(String id) async {
    CommonUtilities.showLoadingDialog(context);
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getEventByIdEndPoint + id,
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
          CommonUtilities.hideLoadingDialog(context);
          setState(() {
            eventDetails = eventList;
            setData(); // your list variable
          });
        } else {
          CommonUtilities.hideLoadingDialog(context);
        }
      } else {
        CommonUtilities.hideLoadingDialog(context);
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded successfully!')));
    } catch (e) {
      CommonUtilities.hideLoadingDialog(context);
      log("Error: ${e.toString()}");
      // print("Upload error: $e");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed!')));
    }
  }
  Future<void> createEventDetails() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    CommonUtilities.showLoadingDialog(context);
    List<String> selectedGamesIds = selectedGames.map((game) => game.id).toList();
    List<String> selectedEventTypeIds = selectedEventType.map((eventType) => eventType.id).toList();

    var formData = jsonEncode({
      "name": eventNameCtrl.text,
      "startDate": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(eventStartDateCtrl.text)),
      "endDate": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(eventEndDateCtrl.text)),
      "registrationStartDate": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(registrationStartDateCtrl.text)),
      "registrationEndDate": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(registrationEndDateCtrl.text)),
      "description": descriptionCtrl.text,
      "eventTypes": selectedEventTypeIds,
      "games": selectedGamesIds,
      // "isPaid": isPaid.toString(),
    });
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.createEventEndPoint,
        payload: formData,
        method: MethodType.post,
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      // if (!mounted) return;
      if (response.status == "200" || response.status == "201") {
        if (response.data["status"] == 200 || response.data["status"] == 201) {

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
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: Icon(Icons.check_circle, color: Colors.green, size: 50),
          );
          CommonUtilities.showToast(response.data['message']);
        }
        // CommonUtilities.showToast("Successfully sign up");
      } else {
        CommonUtilities.showToast(response.data['message']);
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
  Future<void> updateEventDetails() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    List<String> selectedGamesIds = selectedGames.map((game) => game.id).toList();
    List<String> selectedEventTypeIds = selectedEventType.map((eventType) => eventType.id).toList();
    CommonUtilities.showLoadingDialog(context);
    var formData = jsonEncode({
      "name": eventNameCtrl.text,
      "startDate": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(eventStartDateCtrl.text)),
      "endDate": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(eventEndDateCtrl.text)),
      "registrationStartDate": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(registrationStartDateCtrl.text)),
      "registrationEndDate": DateFormat("yyyy-MM-dd")
          .format(DateFormat("dd-MM-yyyy").parse(registrationEndDateCtrl.text)),
      "description": descriptionCtrl.text,
      "eventTypes": selectedEventTypeIds,
      "games": selectedGamesIds,
      // "isPaid": isPaid.toString(),
    });
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.updateEventEndPoint+eventDetails.id,
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
  void setData() {
    // Match by ID to get the right object instances
    selectedGames = eventDetails.games
       /* .map((g) => games.firstWhere((x) => x.id == g.id, orElse: () => g))
        .toList()*/;

    selectedEventType = eventDetails.eventtypes
        /*.map((e) => eventTypes.firstWhere((x) => x.id == e.id, orElse: () => e))
        .toList()*/;

    eventNameCtrl.text = eventDetails.name;
    descriptionCtrl.text = eventDetails.description;
    eventStartDateCtrl.text = DateFormat("dd-MM-yyyy")
        .format(DateFormat("yyyy-MM-dd").parse(eventDetails.startDate));
    eventEndDateCtrl.text = DateFormat("dd-MM-yyyy")
        .format(DateFormat("yyyy-MM-dd").parse(eventDetails.endDate));
    registrationStartDateCtrl.text = DateFormat("dd-MM-yyyy")
        .format(DateFormat("yyyy-MM-dd").parse(eventDetails.registrationStartDate));
    registrationEndDateCtrl.text = DateFormat("dd-MM-yyyy")
        .format(DateFormat("yyyy-MM-dd").parse(eventDetails.registrationEndDate));
    setState(() {});
  }

  Future<void> setGamesDropdownList() async {
    // CommonUtilities.showLoadingDialog(context);
    Map<String, dynamic> query = {
      "page": 1,
      "type":"event"
    };
    try {
      final response = await DioClient().request(
          path: ApiEndPoints.getGameListEndPoint,
          method: MethodType.get,
          queryParameters: query
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      if(response.status == "200" || response.status == "201"){
        // final List<dynamic> jsonList = response.data["data"];

        if(response.data['status'] == 200){
          final data = response.data['data'];
          final List<dynamic> gamesListJson = data['gameDetails']; // extract the list

          List<GameDetailsModel> gamesList = gamesListJson
              .map((json) => GameDetailsModel.fromJson(json))
              .toList();

          setState(() {
            games = gamesList;
          });
          setEventTypeDropDown();
        }else{
          CommonUtilities.showAlertDialog(context, message: response.data['message'],icon: Icon(Icons.warning_amber,color: Colors.red,size: 50,));
        }
      }else{
        CommonUtilities.showAlertDialog(context, message: response.data['message'],icon: Icon(Icons.warning_amber,color: Colors.red,size: 50,));
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded successfully!')));
    } catch (e) {
      log("Error: ${e.toString()}");
      // print("Upload error: $e");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed!')));
    }
  }
  Future<void> setEventTypeDropDown() async {
    Map<String, dynamic> query = {
      "page": 1,
      "type":"event"
    };
    try {
      final response = await DioClient().request(
          path: ApiEndPoints.getEventTypeListEndPoint,
          method: MethodType.get,
          queryParameters: query
      );
      log("✅ API Response: ${response.status} - ${response.message}");

      setState(() {
        apiResponse = response;
      });
      if(response.status == "200" || response.status == "201"){
        // final List<dynamic> jsonList = response.data["data"];

        if(response.data['status'] == 200){
          final data = response.data['data'];
          final List<dynamic> eventTypeListJson = data['EventTypeDetails']; // extract the list

          List<EventTypeDetailsModel> eventTypeList = eventTypeListJson
              .map((json) => EventTypeDetailsModel.fromJson(json))
              .toList();

          setState(() {
            eventTypes = eventTypeList;// your list variable
          });
          if(widget.isEdit){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Call your API after the first frame (Scaffold available)
              getEventDetailsByIDData(widget.id);
            });
          }
        }else{
          CommonUtilities.showAlertDialog(context, message: response.data['message'],icon: Icon(Icons.warning_amber,color: Colors.red,size: 50,));
        }
      }else{
        CommonUtilities.showAlertDialog(context, message: response.data['message'],icon: Icon(Icons.warning_amber,color: Colors.red,size: 50,));
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded successfully!')));
    } catch (e) {
      log("Error: ${e.toString()}");
      // print("Upload error: $e");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed!')));
    }
  }

}
