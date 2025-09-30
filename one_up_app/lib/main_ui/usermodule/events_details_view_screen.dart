import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/api_service/api_end_points.dart';
import 'package:one_up_app/api_service/api_response.dart';
import 'package:one_up_app/api_service/dio_client.dart';
import 'package:one_up_app/model/event_details_model.dart';
import 'package:one_up_app/utils/common_code.dart';
import '../../api_service/web_client.dart';
import '../../utils/colors.dart';
import '../../utils/common_utilies.dart';
import '../../utils/image_path.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/styled_button.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId; // pass from previous screen
  final bool isOngoingEvent; // pass from previous screen

  const EventDetailsScreen({super.key, required this.eventId, required this.isOngoingEvent});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventDetailsModel? event;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getEventByIdEndPoint + widget.eventId,
        method: MethodType.get,
      );

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];

          setState(() {
            final dynamic eventListJson = data; // extract the list
            event = EventDetailsModel .fromJson(eventListJson);
            // upcomingEventCount = data['Upcoming']; // add if available
          });
        } else {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
          );
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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> registerUserToEvent() async{
    var formData = jsonEncode({
      'eventId': widget.eventId
    });
    try {
      final response = await DioClient().request(
        path: ApiEndPoints.eventRegistrationEndPoint,
        method: MethodType.post,
        payload: formData
      );

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final data = response.data['data'];

          setState(() {
            /*ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registered successfully!")),
            );*/
            CommonUtilities.showAlertDialog(context, message: "Registered successfully!", icon: Icon(Icons.verified_outlined,color: Colors.green,));
            // Navigator.pop(context);
          });
        } else {
          CommonUtilities.showAlertDialog(
            context,
            message: response.data['message'],
            icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
          );
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
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isOngoing() {
    if (event == null) return false;
    final now = DateTime.now();
    final start = DateTime.tryParse(event!.startDate ?? '') ?? DateTime.now();
    final end = DateTime.tryParse(event!.endDate ?? '') ?? DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  bool _isEnded() {
    if (event == null) return false;
    final now = DateTime.now();
    final end = DateTime.tryParse(event!.endDate ?? '') ?? DateTime.now();
    return now.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return  Scaffold(
        body: Center(child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ),),
      );
    }

    if (event == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load event details")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event!.name,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Lato'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: const CustomAppBar(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 2,color: widget.isOngoingEvent ? AppColors.primaryBlue : Colors.green),
              ),
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event!.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        "Event Start Date: ",
                        style: const TextStyle(fontSize: 14, color: Colors.black,fontFamily: 'Lato',),
                      ),
                      Expanded(
                        child: Text(
                          CommonCode.setDateFormat(event!.startDate),
                          style: const TextStyle(fontSize: 14, color: Colors.black54,fontFamily: 'Lato',),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.black,),
                      const SizedBox(width: 8),
                      Text(
                        "Event End Date: ",
                        style: const TextStyle(fontSize: 14, color: Colors.black,fontFamily: 'Lato',),
                      ),
                      Expanded(
                        child: Text(
                          CommonCode.setDateFormat(event!.endDate),
                          style: const TextStyle(fontSize: 14, color: Colors.black54,fontFamily: 'Lato',),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Text("Description",style: TextStyle(fontSize: 14, color: Colors.black,fontFamily: 'Lato',),),
                  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                              color: Colors.black45
                          )
                      ),
                      child: Padding(padding: EdgeInsets.all(15),
                        child: Text(
                          event!.description ?? "No description available",
                          style: TextStyle(fontSize: 12, color: Colors.black38,fontFamily: 'Lato',),
                        ),
                      )
                  ),
                  const SizedBox(height: 20),

                  _buildEventFeesModel()
                ],
              ),),
            Align(
              alignment: Alignment.topCenter,
              child: Image(
                image: AssetImage(widget.isOngoingEvent ? eventView : completedEventImage),
                height: 450,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: widget.isOngoingEvent ? () {
            registerUserToEvent();
          } : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: widget.isOngoingEvent ? AppColors.primaryBlue : Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            widget.isOngoingEvent ? "Register" : "Event Ended",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ),

    );
  }
  Widget _buildEventFeesModel(){
    return  Material(
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
                  'Event Fees Payment',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Lato',
                      fontSize: 15
                  ),
                ),),
              ElevatedButton(
                onPressed: () {
                  eventFeesPaymentView();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Padding(padding: EdgeInsets.symmetric(horizontal: 5),child: Text(
                  "Click here to pay fees",
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),) ,
              ),
            ],
          ) ),

    );
  }
  void eventFeesPaymentView(){
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Events Fees Payment",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato',
                ),
              ),
              const SizedBox(height: 20),

              /// Payment Details
              Row(
                children: const [
                  Icon(Icons.payments_outlined, size: 22, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    "Payable amount:",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.currency_rupee, size: 22, color: Colors.green),
                  SizedBox(width: 2),
                  Text(
                    "100",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Notes
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Note",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.black26),
                ),
                padding: const EdgeInsets.all(12),
                child: const Text(
                  "No description available",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
            ],
          ),

          /// Action Buttons
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            StyledButton(
              text: "Proceed Payment",
              onPressed: () {
                Navigator.pop(context);
                // TODO: Call payment API
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
      },
    );
    /*showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content:
          Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                     Text("Events Fees Payment",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato',

                        ),
                      ),
                Container(

                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.payments_outlined, size: 20, color: Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            "Payable amount: ",
                            style: const TextStyle(fontSize: 14, color: Colors.black,fontFamily: 'Lato',),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "100",
                            style: const TextStyle(fontSize: 16, color: Colors.green,fontFamily: 'Lato',),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.currency_rupee, size: 20, color: Colors.green,),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Description
                      Text("Note",style: TextStyle(fontSize: 14, color: Colors.black,fontFamily: 'Lato',),),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                color: Colors.black45
                            )
                        ),
                        padding: EdgeInsets.all(15),

                        child: Text(
                          "No description available",
                          style: TextStyle(fontSize: 14, color: Colors.black38,fontFamily: 'Lato',),
                        ),
                      )
                    ],
                  ),),
              ]
          )
          ,
          actions: [
            StyledButton(text: "Proceed payment",onPressed: ()=>{
              Navigator.pop(context)
            }),
            SizedBox(height: 10,),
            StyledButton(text: "Cancel",onPressed: ()=>{
              Navigator.pop(context)
            })
          ],
        );
      },
    );*/
  }
}
