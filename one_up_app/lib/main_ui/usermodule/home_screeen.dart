
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/main_ui/usermodule/event_status_count_screen.dart';
import 'package:one_up_app/main_ui/usermodule/user_events_listing.dart';

import '../../api_service/api_end_points.dart';
import '../../api_service/dio_client.dart';
import '../../api_service/web_client.dart';
import '../../model/event_details_model.dart';
import '../../utils/app_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/common_code.dart';
import '../../utils/common_utilies.dart';
import '../../utils/image_path.dart';
import '../../widgets/styled_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EventDetailsModel> eventDetails = [];
  bool isLoading = false; // initial loader
  bool isLoadingMore = false; // pagination loader
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AppPreferences.init();
    _fetchRegisteredEvents(initialLoad: true);
    _scrollController.addListener(_scrollListener);
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      _fetchRegisteredEvents();
    }
  }

  Future<void> _fetchRegisteredEvents({bool refresh = false, bool initialLoad = false}) async {
    if (initialLoad) {
      setState(() => isLoading = true);
    } else {
      setState(() => isLoadingMore = true);
    }

    if (refresh) {
      currentPage = 1;
      eventDetails.clear();
      hasMore = true;
    }

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getUserRegisteredEventsEndPoint,
        method: MethodType.get,
        /*queryParameters: {
          "page": currentPage,
          "perPage": pageSize,
        },*/
      );

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final List<dynamic> eventTypeListJson = response.data['data'];

          List<EventDetailsModel> newItems = eventTypeListJson
              .map((json) => EventDetailsModel.fromJson(json))
              .toList();

          setState(() {
            if (refresh || initialLoad) {
              eventDetails = newItems;
            } else {
              eventDetails.addAll(newItems);
            }

            if (newItems.isNotEmpty) currentPage++;
            if (newItems.length < pageSize) hasMore = false;
          });
        } else {
          _showError(response.data['message']);
        }
      } else {
        _showError(response.data['message']);
      }
    } catch (e) {
      log("❌ Error: ${e.toString()}");
      _showError("Something went wrong!");
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _showError(String message) {
    CommonUtilities.showAlertDialog(
      context,
      message: message,
      icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50),
    );
  }
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = jsonDecode(AppPreferences.getUserSession());
    if (isLoading) {
      return  Center(child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ),);
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(bottom: 20,right: 25,left: 25),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                  'Welcome ${userData["name"]}!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato'
                  )
              ),
              const SizedBox(height: 8),
              Text(
                  'Stay organized with your upcoming events',
                  style:TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato'
                  )
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(top: 20),
          child: const Text(
            "Registered Events",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lato',
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _fetchRegisteredEvents(refresh: true, initialLoad: true),
            child: eventDetails.isEmpty
                ? const Center(child: Text("No Events found"))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: eventDetails.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < eventDetails.length) {
                  return _buildDetailTile(
                    eventDetails[index],
                    icon: Icons.emoji_events,
                  );
                } else {
                  return  Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Lottie.asset(
                        'assets/animations/loader.json',
                        width: 120,
                        height: 120,
                        repeat: true,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile(EventDetailsModel event, {IconData? icon}) {
    return InkWell(
      onTap: () {
        // Navigation logic (if needed)
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.getDashboardTileColors(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  registeredEventImage,
                  width: 32,
                  height: 32,
                ),

                const SizedBox(width: 8),

                /// ✅ Fix: Expanded is now directly under Row
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      event.name,
                      textAlign: TextAlign.center,
                      maxLines: 1, // 👈 prevent overflow
                      overflow: TextOverflow.ellipsis, // 👈 add dots if too long
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black38,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: () => eventDetailsView(event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.all(8),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.remove_red_eye_sharp, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void eventDetailsView(EventDetailsModel event){
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content:
          Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text("Events Details",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ),
                    IconButton(
                        iconSize: 24,
                        onPressed: (){
                          Navigator.pop(context);
                        }, icon: Icon(Icons.cancel,color: Colors.green,))
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(width: 2,color: Colors.green),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
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
                              CommonCode.setDateFormat(event.startDate),
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
                              CommonCode.setDateFormat(event.endDate),
                              style: const TextStyle(fontSize: 14, color: Colors.black54,fontFamily: 'Lato',),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Description
                      Text("Description",style: TextStyle(fontSize: 14, color: Colors.black,fontFamily: 'Lato',),),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                color: Colors.black45
                            )
                        ),
                        padding: EdgeInsets.all(15),

                        child: Text(
                          event.description ?? "No description available",
                          style: TextStyle(fontSize: 14, color: Colors.black38,fontFamily: 'Lato',),
                        ),
                      )
                    ],
                  ),),
              ]
          ),
          /*actions: [
            StyledButton(text: "Cancel",onPressed: ()=>{
              Navigator.pop(context)
            })
          ],*/
        );
      },
    );
  }

}
