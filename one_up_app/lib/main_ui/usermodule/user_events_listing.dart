import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:one_up_app/model/event_details_model.dart';
import 'package:one_up_app/utils/common_code.dart';

import '../../api_service/api_end_points.dart';
import '../../api_service/api_response.dart';
import '../../api_service/dio_client.dart';
import '../../api_service/web_client.dart';
import '../../utils/app_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/common_utilies.dart';
import '../../widgets/custom_app_bar.dart';
import 'events_details_view_screen.dart';

class UserEventsListing extends StatefulWidget {
  final String eventStatus;
  final String id;
  const UserEventsListing({super.key, required this.eventStatus, required this.id});

  @override
  State<UserEventsListing> createState() => _UserEventsListingState();
}

class _UserEventsListingState extends State<UserEventsListing> {
  late ApiResponse apiResponse;
  List<EventDetailsModel> eventDetails = [];
  bool isLoading = false; // for first load
  bool isLoadingMore = false; // for pagination
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;
  bool isOnGoing = false;
  String status = "";

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if(widget.eventStatus.contains("Upcoming")){
      status = "upcoming";
    }else if(widget.eventStatus.contains("Active")){
      status = "ongoing";
    } else{
      status = "completed";
    }
    AppPreferences.init();
    _fetchEventTypes(initialLoad: true); // load first page
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMore) {
      _fetchEventTypes();
    }
  }

  Future<void> _fetchEventTypes(
      {bool refresh = false, bool initialLoad = false}) async {
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

    Map<String, dynamic> query = {
      "status": status
    };

    try {
      final response = await DioClient().request(
        path: ApiEndPoints.getEventByStatusEndPoint + widget.id,
        method: MethodType.get,
        queryParameters: query,
      );

      log("✅ API Response: ${response.status} - ${response.message}");

      if (response.status == "200" || response.status == "201") {
        if (response.data['status'] == 200) {
          final List<dynamic> eventListJson= response.data['data']; // outer map
          // final List<dynamic> eventListJson = data['data']; // inner "data" list

          List<EventDetailsModel> newItems =eventListJson
              .map((json) => EventDetailsModel.fromJson(json))
              .toList();


          setState(() {
            if (refresh || initialLoad) {
              eventDetails = newItems;
            } else {
              eventDetails.addAll(newItems);
            }

            // eventDetails = eventDetails.reversed.toList();

            if (newItems.isNotEmpty) {
              currentPage++;
            }

            if (newItems.length < pageSize) {
              hasMore = false;
            }
          });
        } else {
          CommonUtilities.showAlertDialog(context,
              message: response.data['message'],
              icon:
                  const Icon(Icons.warning_amber, color: Colors.red, size: 50));
        }
      } else {
        CommonUtilities.showAlertDialog(context,
            message: response.data['message'],
            icon: const Icon(Icons.warning_amber, color: Colors.red, size: 50));
      }
    } catch (e) {
      log("Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.eventStatus} Events",
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontFamily: 'Lato'),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: const CustomAppBar(),
        ),
        body: isLoading
            ?  Center(
                child: Lottie.asset(
        'assets/animations/loader.json',
        width: 120,
        height: 120,
        repeat: true,
      ), // 🔹 Loader in center
              )
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          _fetchEventTypes(refresh: true, initialLoad: true),
                      child: eventDetails.isEmpty
                          ? const Center(child: Text("No Events Found"))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16.0),
                              itemCount:
                                  eventDetails.length + (isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < eventDetails.length) {
                                  return _buildDetailTile(
                                    eventDetails[index].id,
                                    eventDetails[index].name,
                                    icon: Icons.event_seat,
                                  );
                                } else {
                                  // 🔹 Bottom loader only for pagination
                                  return  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
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
              ));
  }

  Widget _buildDetailTile(String id, String title, {IconData? icon}) {
    return InkWell(
      onTap: () {

      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          /*gradient: LinearGradient(
            colors: AppColors.getTileColor(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),*/
          color:widget.eventStatus.contains('Completed')? Colors.green : AppColors.primaryBlue ,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              offset: const Offset(3, 5),
              blurRadius: 10,
            ),
          ],
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(eventId: id, isOngoingEvent: (widget.eventStatus.contains('Completed'))? false : true,),
                    ),
                  );
                },
                icon: Icon(Icons.double_arrow_sharp,color: Colors.white,))
          ],
        ),
      ),
    );
  }
}
